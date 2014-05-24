//
//  BindingHelperClasses.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 05.05.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark -
#pragma mark Helper classes

#pragma mark Simple Invocation Checker

@interface SimpleInvocationChecker : NSObject
@property (readonly, nonatomic) BOOL calledInit;

- (NSInteger) integerMethodNoParams;
- (float)       floatMethodNoParams;
- (BOOL)         boolMethodNoParams;
- (NSString *) stringMethodNoParams;
- (id)            nilMethodNoParams;
- (void *)    pointerMethodNoParams;


- (NSInteger) integerMethodReturnParam: (NSInteger)  param;
- (float)       floatMethodReturnParam: (float)      param;
- (BOOL)         boolMethodReturnParam: (BOOL)       param;
- (NSString *) stringMethodReturnParam: (NSString *) param;
- (void *)    pointerMethodReturnParam: (void *)     param;
- (id)         objectMethodReturnParam: (id)         param;

@end


#pragma mark Initializer Checker

@interface InitializerChecker : NSObject
@property (readonly, nonatomic) NSInteger    intProperty;
@property (readonly, nonatomic) float      floatProperty;
@property (readonly, nonatomic) BOOL        boolProperty;
@property (readonly, nonatomic) NSString *stringProperty;
@property (readonly, nonatomic) void    *pointerProperty;

- (id) initWithInt:     (NSInteger)     intValue;
- (id) initWithFloat:   (float)       floatValue;
- (id) initWithBOOL:    (BOOL)         boolValue;
- (id) initWithString:  (NSString *) stringValue;
- (id) initWithPointer: (void *)    pointerValue;

@end