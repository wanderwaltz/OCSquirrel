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

- (void) pushInteger: (SQInteger) value;
- (void) pushFloat:   (SQFloat)   value;
- (void) pushBool:    (BOOL)      value;

- (void) pushString:  (NSString *) string;

- (void) pushUserPointer: (SQUserPointer) pointer;
- (void) pushSQObject: (HSQOBJECT) object;

- (void) pushNull;



- (SQInteger) integerAtPosition: (SQInteger) position;
- (NSString *) stringAtPosition: (SQInteger) position;

@end