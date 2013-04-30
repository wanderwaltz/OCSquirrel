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
    
    OCSquirrelVM_SetInstanceUP(vm, 1, instance);
    
    return 0;
}