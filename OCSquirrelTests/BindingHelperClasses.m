//
//  BindingHelperClasses.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 05.05.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "BindingHelperClasses.h"


#pragma mark -
#pragma mark SimpleInvocationChecker implementation

@implementation SimpleInvocationChecker

- (id) init
{
    self = [super init];
    
    if (self != nil)
    {
        _calledInit = YES;
    }
    return self;
}


- (NSInteger) integerMethodNoParams
{
    return 123456;
}


- (float) floatMethodNoParams
{
    return 123.456;
}


- (BOOL) boolMethodNoParams
{
    return YES;
}


- (NSString *) stringMethodNoParams
{
    return @"test";
}


- (id) nilMethodNoParams
{
    return nil;
}


- (void *) pointerMethodNoParams
{
    return (__bridge void *)self;
}


- (NSInteger) integerMethodReturnParam: (NSInteger)  param
{
    return param;
}


- (float) floatMethodReturnParam: (float) param
{
    return param;
}


- (BOOL) boolMethodReturnParam: (BOOL) param
{
    return param;
}


- (NSString *) stringMethodReturnParam: (NSString *) param
{
    return param;
}


- (void *) pointerMethodReturnParam: (void *) param
{
    return param;
}


- (id) objectMethodReturnParam: (id) param
{
    return param;
}

@end


#pragma mark -
#pragma mark Initializer checker implementation

@implementation InitializerChecker

- (id) init
{
    return (self = nil);
}

@end

