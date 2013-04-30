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


SQRESULT OCSquirrelVM_SetInstanceUP(HSQUIRRELVM vm, SQInteger index, id object)
{
    [object retain];
    
    SQRESULT result = sq_setinstanceup(vm, index, object);
    
    if (SQ_FAILED(result))
    {
        [object release];
    }
    
    return result;
}


SQInteger OCSquirrelVM_InstanceUPReleaseHook(SQUserPointer pointer, SQInteger size)
{
    id object = (id)pointer;
    [object release];
    
    return 0;
}