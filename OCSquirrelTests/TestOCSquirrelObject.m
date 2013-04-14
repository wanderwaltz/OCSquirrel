//
//  TestOCSquirrelObject.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 14.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "TestOCSquirrelObject.h"


#pragma mark -
#pragma mark TestOCSquirrelObject implementation

@implementation TestOCSquirrelObject

- (void) setUp
{
    [super setUp];
    _squirrelVM = [[OCSquirrelVM alloc] init];
}


- (void) tearDown
{
    _squirrelVM = nil;
    [super tearDown];
}


- (void) testOCSquirrelObjectClassExists
{
    STAssertNotNil([OCSquirrelObject class],
                   @"OCSquirrelObject class should exist.");
}


- (void) testHasReadonlySquirrelVMProperty
{
    STAssertTrue( [OCSquirrelObject instancesRespondToSelector: @selector(squirrelVM)] &&
                 ![OCSquirrelObject instancesRespondToSelector: @selector(setSquirrelVM:)],
                 @"OCSquirrelObject class should have a squirrelVM property.");
}


- (void) testThrowsIfSquirrelVMNotSet
{
    // This test verifies that OCSquirrelObject cannot work properly without
    // an OCSquirrelVM. Readonly property can only get its value while initializing
    // the OCSquirrelObject and if the VM is not set, all other OCSquirrelObject
    // behavior is undefined. That should obviously throw an exception.
    STAssertThrowsSpecificNamed([[OCSquirrelObject new] squirrelVM],
                                NSException, NSInternalInconsistencyException,
                                @"OCSquirrelObject should throw and NSInternalInconsistencyException "
                                @"if trying to access squirrelVM property while its value has not "
                                @"been set");
}


- (void) testInitWithVMMethodExists
{
    STAssertNotNil([[OCSquirrelObject alloc] initWithVM: _squirrelVM],
                   @"OCSquirrelObject should have an -initWithSquirrelVM initializer method.");
}


- (void) testNoThrowWhenVMSet
{
    OCSquirrelObject *object = [[OCSquirrelObject alloc] initWithVM: _squirrelVM];
    STAssertEqualObjects(object.squirrelVM, _squirrelVM,
                         @"Should not throw exception if VM has been set in initializer.");
}

@end
