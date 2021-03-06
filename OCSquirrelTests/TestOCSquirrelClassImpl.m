//
//  TestOCSquirrelClassImpl.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 27.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#ifndef GHUnit_Target
    #import <XCTest/XCTest.h>
#endif

#import <OCSquirrel/OCSquirrel.h>
#import "OCSquirrelVM+Protected.h"
#import "OCSquirrelClassImpl.h"


#pragma mark -
#pragma mark TestOCSquirrelClassImpl interface

@interface TestOCSquirrelClassImpl : XCTestCase
{
    OCSquirrelVM *_squirrelVM;
    OCSquirrelClassImpl *_class;
}

@end



#pragma mark -
#pragma mark TestOCSquirrelClassImpl implementation

@implementation TestOCSquirrelClassImpl

- (void) setUp
{
    [super setUp];
    _squirrelVM = [[OCSquirrelVM alloc] init];
    _class      = [[OCSquirrelClassImpl alloc] initWithVM: _squirrelVM];
}


- (void) tearDown
{
    _class      = nil;
    _squirrelVM = nil;
    [super tearDown];
}


#pragma mark -
#pragma mark basic tests

- (void) testSetAttributeForNilKey
{
    [_class setClassAttributes: @12345];

    [_class push];
    [_squirrelVM.stack pushValue: nil];
    sq_getattributes(_squirrelVM.vm, -2);
    XCTAssertEqualObjects([_squirrelVM.stack valueAtPosition: -1], @12345,
                         @"-setClassAttributes: should set the class attributes.");
}


- (void) testClassAttributeForNilKey
{
    [_class setClassAttributes: @12345];
    
    XCTAssertEqualObjects([_class classAttributes], @12345,
                         @"-classAttributes should get the class attributes.");
}


- (void) testPushNewInstance
{
    OCSquirrelClassImpl *class = [OCSquirrelClassImpl newWithVM: _squirrelVM];
    
    [class pushNewInstance];
    
    id instance = [_squirrelVM.stack valueAtPosition: -1];
    
    XCTAssertTrue([instance isKindOfClass: [OCSquirrelInstance class]],
                 @"pushNewInstance method should push an instance of the class "
                 @"to the OCSquirrelVM stack.");
}


- (void) testNewInstanceUserPointer
{
    OCSquirrelClassImpl *class = [OCSquirrelClassImpl newWithVM: _squirrelVM];
    
    [class pushNewInstance];
    
    OCSquirrelInstance *instance = [_squirrelVM.stack valueAtPosition: -1];
    
    XCTAssertNil(instance.instanceUP,
                @"New class instance should not have a instanceUP userpointer.");
}

@end
