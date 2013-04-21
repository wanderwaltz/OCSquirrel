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
    __weak OCSquirrelVM *_squirrelVM;
}

@property (assign, nonatomic) NSInteger top;

- (id) initWithSquirrelVM: (OCSquirrelVM *) squirrelVM;

- (void) pushInteger: (SQInteger) value;
- (void) pushString: (NSString *) string;

- (SQInteger) integerAtPosition: (SQInteger) position;
- (NSString *) stringAtPosition: (SQInteger) position;

@end
