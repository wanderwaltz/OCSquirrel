//
//  OCSquirrelVMBindings.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 4/30/13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (__has_feature(objc_arc))
#error "This file should be compiled without ARC"
#endif

#import "OCSquirrelVMBindings_NoARC.h"
#import "OCSquirrelVM.h"
#import "OCSquirrelVMFunctions.h"
#import "OCSquirrelVMFunctions_NoARC.h"


/*! Implementation for constructor() method of the Squirrel classes bound to Objective-C classes.
    This implementation actually only +allocs the instance, but does not initialize it, so the
    initializer methods should be called afterwards similar to how it would be done in Objective-C
    with NSObject subclasses.
 
    Because of that semantics, constructor method does not accept any parameters.
 */
SQInteger OCSquirrelVMBindings_Constructor(HSQUIRRELVM vm)
{
    SQUserPointer nativeClassPtr = nil;
    Class         nativeClass    = nil;

    sq_getclass(vm, 1);
    sq_pushnull(vm);
    sq_getattributes(vm, -2);
    sq_getuserpointer(vm, -1, &nativeClassPtr);
    
    nativeClass = (Class)nativeClassPtr;
    
    id instance = [nativeClass alloc]; // Retain count +1
    
    if (SQ_SUCCEEDED(OCSquirrelVM_SetInstanceUP(vm, 1, instance))) // Retain count +1
    {
        [instance release]; // Retain count -1
        sq_setreleasehook(vm, 1, OCSquirrelVM_InstanceUPReleaseHook);
    }
    else {
        [instance release]; // Retain count -1
        return SQ_ERROR;
    }
    
    // Total retain count delta of the instance should be +1 at this point
    // The last retain should be compensated by the release in
    // OCSquirrelVM_InstanceUPReleaseHook which will be called when the
    // corresponding Squirrel object gets deleted.
    
    return 0;
}



/// This function is used internally by other binding implementations
void _setArgumentAtIndex(NSUInteger i,
                         HSQUIRRELVM vm,           // Have to pass both HSQUIRRELVM
                         OCSquirrelVM *squirrelVM, // and OCSquirrelVM here since both
                         const char *argumentType, // C and Objective-C APIs are used
                         NSInvocation *invocation)
{
    // NSInvocation accepts its arguments as void* buffers, so we
    // generally have to actually check which type of argument it
    // expects and give it the buffer of the proper size and layout.
    // To do that we check the argument type string and compare it
    // to @encodings of various C types available. If a match is found,
    // we fetch an SQInteger from the Squirrel VM stack and cast
    // it to a local variable of the proper type.
    //
    // This is done multiple times for various int types of different
    // sizes and the code is essentially the same, so it is implemented
    // using parametric #define. This macro is undefined later in this
    // function.
    //
    // For now I don't know a better way to pass arguments from
    // Squirrel VM to the NSInvocation, but it seems that these runtime
    // checks will have a significant impact on performance. Should
    // think about doing this more efficiently.
    #define OCSQ_TRY_TYPE_INT(Type)                               \
        if (strcmp(argumentType, @encode(Type)) == 0)             \
        {                                                         \
            SQInteger stackInt = 0;                               \
            sq_getinteger(vm, i, &stackInt);                      \
            Type argument = stackInt;                             \
            [invocation setArgument: &argument atIndex: i];       \
        }
    
    // Floating point parameters require the same effort since NSInvocation
    // may expect either float or double, but Squirrel VM works only in terms
    // of SQFloats which could be either float or double themselves. So we
    // have to typecast here to the proper type.
    #define OCSQ_TRY_TYPE_FLOAT(Type)                             \
        if (strcmp(argumentType, @encode(Type)) == 0)             \
        {                                                         \
            SQFloat stackFloat = 0.0;                             \
            sq_getfloat(vm, i, &stackFloat);                      \
            Type argument = stackFloat;                           \
            [invocation setArgument: &argument atIndex: i];       \
        }

         OCSQ_TRY_TYPE_INT(   int8_t)
         OCSQ_TRY_TYPE_INT(  int16_t)
    else OCSQ_TRY_TYPE_INT(  int32_t)
    else OCSQ_TRY_TYPE_INT( u_int8_t)
    else OCSQ_TRY_TYPE_INT(u_int16_t)
    else OCSQ_TRY_TYPE_INT(u_int32_t)
        
    else OCSQ_TRY_TYPE_FLOAT(float)
    else OCSQ_TRY_TYPE_FLOAT(double)
        
    else if (strcmp(argumentType, @encode(BOOL)) == 0)
    {
        SQBool stackBool = SQFalse;
        
        sq_getbool(vm, i, &stackBool);
        
        BOOL argument = (stackBool == SQTrue);
        [invocation setArgument: &argument atIndex: i];
    }
    else if (strcmp(argumentType, @encode(id)) == 0)
    {
        id argument = [squirrelVM.stack valueAtPosition: i];
        
        // Pointers to Objective-C objects are passed as user pointers
        // and user pointers are returned as NSValues.
        //
        // Special cases are NSStrings and NSNumbers which are
        // returned directly as NSStrings and NSNumbers.
        if ([argument isKindOfClass: [NSValue class]])
        {
            argument = (id)[argument pointerValue];
        }
        
        [invocation setArgument: &argument atIndex: i];
    }
    else if (strcmp(argumentType, @encode(void*)) == 0)
    {
        void *argument = NULL;
        sq_getuserpointer(vm, i, &argument);
        
        [invocation setArgument: &argument atIndex: i];
    }
    
    #undef OCSQ_TRY_TYPE_INT
    #undef OCSQ_TRY_TYPE_FLOAT
}


/*! This function is used internally by other binding implementations.
    Returns YES if pushed return value to the Squirrel VM stack.
 */
BOOL _pushReturnValueAtIndex(HSQUIRRELVM vm,           // Have to pass both HSQUIRRELVM
                             OCSquirrelVM *squirrelVM, // and OCSquirrelVM here since both
                             const char   *returnType, // C and Objective-C APIs are used
                             NSInvocation *invocation)
{
    // Similar to the _setArgumentAtIndex we have to check
    // the actual @encodings of the possible return value types
    // and read the return value to the buffer of an appropriate
    // size.
    #define OCSQ_TRY_TYPE_INT(Type)                 \
        if (strcmp(returnType, @encode(Type)) == 0) \
        {                                           \
            Type result = 0;                        \
            [invocation getReturnValue: &result];   \
            sq_pushinteger(vm, (SQInteger)result);  \
        }

    
    #define OCSQ_TRY_TYPE_FLOAT(Type)               \
        if (strcmp(returnType, @encode(Type)) == 0) \
        {                                           \
            Type result = 0.0;                      \
            [invocation getReturnValue: &result];   \
            sq_pushfloat(vm, (SQFloat)result);      \
        }
    
         OCSQ_TRY_TYPE_INT(   int8_t)
    else OCSQ_TRY_TYPE_INT(  int16_t)
    else OCSQ_TRY_TYPE_INT(  int32_t)
    else OCSQ_TRY_TYPE_INT( u_int8_t)
    else OCSQ_TRY_TYPE_INT(u_int16_t)
    else OCSQ_TRY_TYPE_INT(u_int32_t)
        
    else OCSQ_TRY_TYPE_FLOAT(float)
    else OCSQ_TRY_TYPE_FLOAT(double)
        
    else if (strcmp(returnType, @encode(BOOL)) == 0)
    {
        BOOL result = NO;
        [invocation getReturnValue: &result];
        
        sq_pushbool(vm, (result == YES) ? SQTrue : SQFalse);
    }
    else if (strcmp(returnType, @encode(id)) == 0)
    {
        id result = nil;
        [invocation getReturnValue: &result];
        
        // This will automatically call some class checks and
        // convert NSNumbers to numbers, NSStrings to C strings etc.
        // If a suitable Squirrel value could not be formed,
        // a user pointer value will be pushed.
        [squirrelVM.stack pushValue: result];
    }
    else if (strcmp(returnType, @encode(void*)) == 0)
    {
        void *result = NULL;
        [invocation getReturnValue: &result];
        
        sq_pushuserpointer(vm, result);
    }
    else return NO;
    
    return YES;
    
    #undef OCSQ_TRY_TYPE_INT
}


/*! Implementation for instance methods simple invocation. Simple invocations accept zero or one parameter
    and may return a value.
 */
SQInteger OCSquirrelVMBindings_Instance_SimpleInvocation(HSQUIRRELVM vm)
{
    OCSquirrelVM *squirrelVM = OCSquirrelVMforVM(vm);
    
    sq_getclosurename(vm, 0);
    NSString *closureName = [squirrelVM.stack valueAtPosition: -1];
    sq_pop(vm, 1);
    
    if ([closureName isKindOfClass: [NSString class]] &&
        ([closureName length] >= 1))
    {
        id object = nil;
        sq_getinstanceup(vm, 1, (SQUserPointer *)&object, 0);
        
        SEL selector = NSSelectorFromString(closureName);
        
        NSMethodSignature *signature = [object methodSignatureForSelector: selector];
        
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature: signature];
        invocation.selector      = selector;

        for (NSUInteger i = 2; i < signature.numberOfArguments; ++i)
        {
            const char *argumentType = [signature getArgumentTypeAtIndex: i];
            
            // This function will read an argument from the Squirrel VM stack
            // and pass it to the invocation.
            _setArgumentAtIndex(i, vm, squirrelVM, argumentType, invocation);
        }
        
        [invocation invokeWithTarget: object];
        
        BOOL didPushValue = _pushReturnValueAtIndex(vm, squirrelVM,
                                                    signature.methodReturnType, invocation);
        
        return (didPushValue ? 1 : 0);
    }

    return 0;
}



/*! Implementation for initializer methods simple invocation. Initializer methods
    are special in the way that they return `self` and allow assignment of `self`
    in these methods. This means we have to replace the Squirrel instance user
    pointer with the return value of the initializer method.
 */
SQInteger OCSquirrelVMBindings_InitializerSimpleInvocation(HSQUIRRELVM vm)
{
    OCSquirrelVM *squirrelVM = OCSquirrelVMforVM(vm);
    
    // Push the name of the closure being called right now to the stack
    sq_getclosurename(vm, 0);
    NSString *closureName = [squirrelVM.stack valueAtPosition: -1];
    
    // Pop the closure name
    sq_pop(vm, 1);
    
    
    // Sanity check, if the closure name is unavailable,
    // fail softly returning `null` value.
    if ([closureName isKindOfClass: [NSString class]])
    {
        // Get the instance user pointer of the `this` object
        id object = nil;
        sq_getinstanceup(vm, 1, (SQUserPointer *)&object, 0);
        
        // Call the method on the user pointer object
        SEL selector = NSSelectorFromString(closureName);
        
        NSMethodSignature *signature = [object methodSignatureForSelector: selector];
        
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature: signature];
        invocation.selector      = selector;
        
        for (NSUInteger i = 2; i < signature.numberOfArguments; ++i)
        {
            const char *argumentType = [signature getArgumentTypeAtIndex: i];
            
            // This function will read an argument from the Squirrel VM stack
            // and pass it to the invocation.
            _setArgumentAtIndex(i, vm, squirrelVM, argumentType, invocation);
        }
        
        [invocation invokeWithTarget: object];
        
        // Get return value
        id returnValue = nil;
        [invocation getReturnValue: &returnValue];
        
        // Initializer methods are expected to return `self` which may actually
        // be not the same as the user pointer we had earlier. So we have to
        // replace the user pointer on the Squirrel class instance.
        //
        // We usually should use the OCSquirrelVM_SetInstanceUP function which
        // both sets instance user pointer, retains the new object and releases
        // the old one, but it seems that this leads to overreleasing the initial
        // user pointer - I guess releasing it is a part of `self = ...` implementation
        // in the Objective-C initializer methods (especially when using ARC).
        // So we just set the instance UP to the new object and do not worry
        // about anything.
        sq_setinstanceup(vm, 1, returnValue);
    
        // Return self
        sq_push(vm, 1);
    }
    else
    {
        // Return nil
        sq_pushnull(vm);   
    }
    
    return 1;
}
