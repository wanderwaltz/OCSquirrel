//
//  OCSquirrelVMBindings.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 4/30/13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "OCSquirrelVMBindings.h"
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
    
    nativeClass = (__bridge Class)nativeClassPtr;
    
    id instance = [nativeClass alloc];
    
    if (SQ_SUCCEEDED(OCSquirrelVM_SetInstanceUP(vm, 1, instance)))
    {
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
        SQUserPointer userPointer = NULL;
        sq_getinstanceup(vm, 1, &userPointer, 0);
        
        id object = (__bridge id)userPointer;
        
        SEL selector = NSSelectorFromString(closureName);
        
        NSMethodSignature *signature = [object methodSignatureForSelector: selector];
        
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature: signature];
        invocation.selector      = selector;
        
        [invocation invokeWithTarget: object];
    }
    
    sq_push(vm, 1);
    
    return 1;
}
