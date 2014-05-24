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
    [object retain]; // A: +1 retain count
    id prevObject = nil;
    
    SQRESULT result = SQ_ERROR;
    
    if (SQ_SUCCEEDED(result = sq_getinstanceup(vm, index, (SQUserPointer *)&prevObject, 0)))
    {
        if (SQ_SUCCEEDED(result = sq_setinstanceup(vm, index, object)))
        {
            // Release the previous user poniter if existed
            // and only if setting new user pointer succeeds.
            // Otherwise releasing prevObject would leave
            // an pointer to deallocated object, which will
            // definitely crash the app at some point. We'll
            // better cope with memory leaks than with crashes.
            [prevObject release];
        }
        else
        {
            [object release]; // Compensate retain in A
        }
    }
    else
    {
        [object release]; // Compensate retain in line A
    }
    
    // In case of the successfull setting the instance user pointer,
    // object should have its retain count increased by 1 and the
    // previous user pointer should be released.
    
    return result;
}


SQInteger OCSquirrelVM_InstanceUPReleaseHook(SQUserPointer pointer, SQInteger size)
{
    id object = (id)pointer;
    [object release];
    
    return 0;
}