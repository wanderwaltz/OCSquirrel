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
    
    // Total retain count delta of the instance should be +1 at this point
    // The last retain should be compensated by the release in
    // OCSquirrelVM_InstanceUPReleaseHook which will be called when the
    // corresponding Squirrel object gets deleted.
    
    return 0;
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
    
    if ([closureName isKindOfClass: [NSString class]])
    {
        id object = nil;
        sq_getinstanceup(vm, 1, (SQUserPointer *)&object, 0);
        
        SEL selector = NSSelectorFromString(closureName);
        
        NSMethodSignature *signature = [object methodSignatureForSelector: selector];
        
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature: signature];
        invocation.selector      = selector;
        
        [invocation invokeWithTarget: object];
        
        
        if (strcmp(signature.methodReturnType, @encode(int16_t)) == 0)
        {
            int16_t result = 0;
            [invocation getReturnValue: &result];
            
            sq_pushinteger(vm, result);
        }
        else if (strcmp(signature.methodReturnType, @encode(int32_t)) == 0)
        {
            int32_t result = 0;
            [invocation getReturnValue: &result];
            
            sq_pushinteger(vm, result);
        }
        else if (strcmp(signature.methodReturnType, @encode(u_int16_t)) == 0)
        {
            u_int16_t result = 0;
            [invocation getReturnValue: &result];
            
            sq_pushinteger(vm, result);
        }
        else if (strcmp(signature.methodReturnType, @encode(u_int32_t)) == 0)
        {
            u_int32_t result = 0;
            [invocation getReturnValue: &result];
            
            sq_pushinteger(vm, result);
        }
        else if (strcmp(signature.methodReturnType, @encode(float)) == 0)
        {
            float result = 0.0f;
            [invocation getReturnValue: &result];
            
            sq_pushfloat(vm, result);
        }
        else if (strcmp(signature.methodReturnType, @encode(double)) == 0)
        {
            double result = 0.0;
            [invocation getReturnValue: &result];
            
            sq_pushfloat(vm, result);
        }
        else if (strcmp(signature.methodReturnType, @encode(BOOL)) == 0)
        {
            BOOL result = NO;
            [invocation getReturnValue: &result];
            
            sq_pushbool(vm, (result == YES) ? SQTrue : SQFalse);
        }
        else if (strcmp(signature.methodReturnType, @encode(id)) == 0)
        {
            id result = nil;
            [invocation getReturnValue: &result];
            
            // This will automatically call some class checks and
            // convert NSNumbers to numbers, NSStrings to C strings etc.
            // If a suitable Squirrel value could not be formed,
            // a user pointer value will be pushed.
            [squirrelVM.stack pushValue: result];
        }
        else if (strcmp(signature.methodReturnType, @encode(void*)) == 0)
        {
            void *result = NULL;
            [invocation getReturnValue: &result];
            
            sq_pushuserpointer(vm, result);
        }
        else
        {
            return 0;
        }
        
        return 1;
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
