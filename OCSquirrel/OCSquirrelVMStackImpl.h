//
//  OCSquirrelVMStackImpl.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 14.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCSquirrel.h"

#pragma mark -
#pragma mark OCSquirrelVMStackImpl interface

/// A helper class designed to contain methods for Squirrel VM stack manipulation.
@interface OCSquirrelVMStackImpl : NSObject<OCSquirrelVMStack>
{
@protected
    // OCSquirrelVM is referenced weakly because the OCSquirrelVM
    // keeps a strong reference to the stack impl
    __weak OCSquirrelVM *_squirrelVM;
}

@property (assign, nonatomic) NSInteger top;

- (id) initWithSquirrelVM: (OCSquirrelVM *) squirrelVM;

#pragma mark pushing methods

- (void) pushInteger: (SQInteger) value;
- (void) pushFloat:   (SQFloat)   value;
- (void) pushBool:    (BOOL)      value;

- (void) pushString: (NSString *) string;

- (void) pushUserPointer: (SQUserPointer) pointer;
- (void) pushSQObject: (HSQOBJECT) object;

- (void) pushNull;

- (void) pushValue: (id) value;


#pragma mark reading methods

- (SQInteger) integerAtPosition: (SQInteger) position;
- (SQFloat)     floatAtPosition: (SQInteger) position;
- (BOOL)         boolAtPosition: (SQInteger) position;
- (NSString *) stringAtPosition: (SQInteger) position;

- (SQUserPointer) userPointerAtPosition: (SQInteger) position;
- (HSQOBJECT) sqObjectAtPosition: (SQInteger) position;


#pragma mark type information

- (BOOL) isNullAtPosition: (SQInteger) position;

@end
