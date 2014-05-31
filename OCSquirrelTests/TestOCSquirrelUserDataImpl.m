//
//  TestOCSquirrelUserDataImpl.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 31.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#ifndef GHUnit_Target
    #import <XCTest/XCTest.h>
#endif

#import <OCSquirrel/OCSquirrel.h>
#import "OCSquirrelVM+Protected.h"
#import "OCSquirrelUserDataImpl.h"

@interface TestOCSquirrelUserDataImpl : XCTestCase
{
    OCSquirrelVM *_squirrelVM;
}

@end

@implementation TestOCSquirrelUserDataImpl

- (void)setUp
{
    [super setUp];
    _squirrelVM = [[OCSquirrelVM alloc] init];
}


- (void)tearDown
{
    _squirrelVM = nil;
    [super tearDown];
}


#pragma mark -
#pragma mark basic tests

- (void)testOCSquirrelUserDataImplClassExists
{
    XCTAssertTrue([OCSquirrelUserDataImpl isSubclassOfClass: [OCSquirrelObjectImpl class]],
                  @"OCSquirrelUserDataImpl class should exist and be a subclass of OCSquirrelObjectImpl");
}


- (void)testNewUserDataInitializingWithVM
{
    OCSquirrelUserDataImpl *userData = [[OCSquirrelUserDataImpl alloc] initWithVM: _squirrelVM];
    
    XCTAssertNotNil(userData, @"Should be able to create OCSquirrelUserDataImpl instances");
}


- (void)testTypeAfterInitializingWithVM
{
    OCSquirrelUserDataImpl *userData = [[OCSquirrelUserDataImpl alloc] initWithVM: _squirrelVM];
    
    XCTAssertEqual(userData.type, OT_USERDATA,
                   @"OCSquirrelUserDataImpl should be a wrapper for OT_USERDATA HSQOBJECT");
}


- (void)testThrowsWhenInitializingWithNull
{
    HSQOBJECT obj;
    sq_resetobject(&obj);
    
    XCTAssertThrowsSpecificNamed(({
        __unused OCSquirrelUserDataImpl *userData = [[OCSquirrelUserDataImpl alloc] initWithHSQOBJECT: obj
                                                                                              inVM: _squirrelVM];
    }), NSException, NSInvalidArgumentException,
                                 @"-initWithHSQOBJECT:inVM: should throw an NSInvalidArgumentException "
                                 @"if the provided HSQOBJECT is not of OT_USERDATA type.");
}


- (void)testObjectPropertyIsNilByDefault
{
    OCSquirrelUserDataImpl *userData = [[OCSquirrelUserDataImpl alloc] initWithVM: _squirrelVM];
    
    XCTAssertNil(userData.object, @"Object property of the OCSquirrelUserDataImpl should be nil by default");
}


- (void)testObjectPropertyIsSetToGivenObject
{
    id object = [NSObject new];
    
    OCSquirrelUserDataImpl *userData = [[OCSquirrelUserDataImpl alloc] initWithObject: object
                                                                                 inVM: _squirrelVM];
    
    XCTAssertEqualObjects(object, userData.object,
                          @"Object property of the OCSquirrelUserDataImpl should be set to the object passed in initializer");
}


- (void)testObjectIsRetainedByOCSquirrelUserDataImpl
{
    id object = [NSObject new];
    
    NSInteger oldRetainCount = [[object valueForKey: @"retainCount"] integerValue];
    
    __unused OCSquirrelUserDataImpl *userData = [[OCSquirrelUserDataImpl alloc] initWithObject: object
                                                                                          inVM: _squirrelVM];
    
    NSInteger newRetainCount = [[object valueForKey: @"retainCount"] integerValue];
    
    XCTAssertEqual(newRetainCount, oldRetainCount+1,
                   @"OCSquirrelUserDataImpl should retain the object");
}


- (void)testObjectIsReleasedWhenHSQOBJECTGetsDestroyed
{
    id object = [NSObject new];
    
    NSInteger oldRetainCount = [[object valueForKey: @"retainCount"] integerValue];
    
    @autoreleasepool {
        OCSquirrelUserDataImpl *userData = [[OCSquirrelUserDataImpl alloc] initWithObject: object
                                                                                     inVM: _squirrelVM];
        
        // The corresponding HSQOBJECT is not referenced by anything else than the userData object and will
        // also get destroyed when we release the userData.
        userData = nil;
    }
    
    NSInteger newRetainCount = [[object valueForKey: @"retainCount"] integerValue];
    
    XCTAssertEqual(newRetainCount, oldRetainCount,
                   @"Object linked to OCSquirrelUserDataImpl should get released "
                   @"when the corresponding HSQOBJECT is destroyed");
}


@end
