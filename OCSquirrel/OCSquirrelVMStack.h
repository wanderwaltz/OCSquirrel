//
//  OCSQuirrelVMStack.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 14.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark -
#pragma mark OCSquirrelVMStack protocol

@protocol OCSquirrelVMStack<NSObject>
@required

@property (assign, nonatomic) NSInteger top;

#pragma mark pushing methods

- (void) pushInteger: (SQInteger) value;
- (void) pushFloat:   (SQFloat)   value;
- (void) pushBool:    (BOOL)      value;

- (void) pushString:  (NSString *) string;

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