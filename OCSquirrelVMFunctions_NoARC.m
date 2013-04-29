//
//  OCSquirrelVMFunctions_NoARC.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 4/29/13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (__has_feature(objc_arc))
#error "This file should be compiled without ARC"
#endif

#import "OCSquirrelVMFunctions_NoARC.h"


void OCSquirrelVM_SetInstanceUP(HSQUIRRELVM vm, HSQOBJECT instance, id object)
{
    SQInteger top = sq_gettop(vm);
    
    sq_pushobject(vm, instance);

    [object retain];
    sq_setinstanceup(vm, -1, object);
    
    sq_settop(vm, top);
}


SQInteger OCSquirrelVM_InstanceUPReleaseHook(SQUserPointer pointer, SQInteger size)
{
    id object = (id)pointer;
    [object release];
    
    return 0;
}