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
    
    id instance = [nativeClass alloc];
    
    if (SQ_SUCCEEDED(OCSquirrelVM_SetInstanceUP(vm, 1, instance)))
    {
        [instance release];
        sq_setreleasehook(vm, 1, OCSquirrelVM_InstanceUPReleaseHook);
    }
    
    return 0;
}


SQInteger OCSquirrelVMBindings_SimpleInvocation(HSQUIRRELVM vm)
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
    }
    
    sq_push(vm, 1);
    
    return 1;
}


SQInteger OCSquirrelVMBindings_InitializerSimpleInvocation(HSQUIRRELVM vm)
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
        
        id returnValue = nil;
        [invocation getReturnValue: &returnValue];
        
        OCSquirrelVM_SetInstanceUP(vm, 1, returnValue);

        sq_push(vm, 1);
    }
    else
    {
        sq_pushnull(vm);   
    }
    
    return 1;
}
