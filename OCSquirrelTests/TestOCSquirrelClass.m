//
//  TestOCSquirrelClass.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 27.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "TestOCSquirrelClass.h"


#pragma mark -
#pragma mark TestOCSquirrelClass implementation

@implementation TestOCSquirrelClass

- (void) setUp
{
    [super setUp];
    _squirrelVM = [[OCSquirrelVM alloc] init];
    _class      = [[OCSquirrelClass alloc] initWithVM: _squirrelVM];
}


- (void) tearDown
{
    _class      = nil;
    _squirrelVM = nil;
    [super tearDown];
}


- (void) testSetAttributeForNilKey
{
    [_class setClassAttributes: @12345];

    [_class push];
    [_squirrelVM.stack pushValue: nil];
    sq_getattributes(_squirrelVM.vm, -2);
    STAssertEqualObjects([_squirrelVM.stack valueAtPosition: -1], @12345,
                         @"-setClassAttribute:forKey: should set the class attribute.");
}


- (void) testClasAttributeForNilKey
{
    [_class setClassAttributes: @12345];
    
    STAssertEqualObjects([_class classAttributes], @12345,
                         @"-classAttribute:forKey: should get the class attribute.");
}


@end
