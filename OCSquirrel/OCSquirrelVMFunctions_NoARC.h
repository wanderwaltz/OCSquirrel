//
//  OCSquirrelVMFunctions_NoARC.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 4/29/13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCSquirrelVM.h"



/*! Attaches the Objective-C object to a given HSQOBJECT at index position 
    in the stack as an instance user pointer.
 
    Retains the Objective-C object.
 */
SQRESULT OCSquirrelVM_SetInstanceUP(HSQUIRRELVM vm, SQInteger index, id object);


/// Releases the Objective-C object represented by the pointer.
SQInteger OCSquirrelVM_InstanceUPReleaseHook(SQUserPointer pointer, SQInteger size);


SQInteger OCSquirrelVM_UserDataReleaseHook(SQUserPointer pointer, SQInteger size);
void OCSquirrelVM_UserDataSetObject(SQUserPointer udp, id object);
id OCSquirrelVM_UserDataGetObject(SQUserPointer udp) NS_RETURNS_NOT_RETAINED;