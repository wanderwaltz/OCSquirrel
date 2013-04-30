//
//  OCSquirrelVMFunctions_NoARC.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 4/29/13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCSquirrelVM.h"



/*! Attaches the Objective-C object to a given HSQOBJECT as an instance user pointer.
    Retains the Objective-C object.
 */
void OCSquirrelVM_SetInstanceUP(HSQUIRRELVM vm, HSQOBJECT instance, id object);


/// Releases the Objective-C object represented by the pointer.
SQInteger OCSquirrelVM_InstanceUPReleaseHook(SQUserPointer pointer, SQInteger size);