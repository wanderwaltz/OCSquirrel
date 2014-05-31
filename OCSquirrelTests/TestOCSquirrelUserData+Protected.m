//
//  TestOCSquirrelUserData+Protected.m
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
#import "OCMock.h"
#import "OCSquirrelVM+Protected.h"
#import "OCSquirrelUserData+Protected.h"
#import "OCSquirrelUserDataImpl.h"

@interface TestOCSquirrelUserData_Protected : XCTestCase
{
    OCSquirrelVM *_squirrelVM;
}
@end

@implementation TestOCSquirrelUserData_Protected

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


#pragma mark - initialization through OCSquirrelVM tests

- (void)testOCSquirrelVMHasImplPropertyAfterInitWithImpl
{
    OCSquirrelUserDataImpl *impl = [[OCSquirrelUserDataImpl alloc] initWithObject: nil inVM: _squirrelVM];
    OCSquirrelUserData *userData = [[OCSquirrelUserData alloc] initWithImpl: impl];
    
    XCTAssertEqualObjects(userData.impl, impl, @"-initWithImpl: should set the impl property of OCSquirrelUserData");
}


- (void)testOCSquirrelVMNewUserDataWithObjectClass
{
    XCTAssertTrue([[_squirrelVM newUserDataWithObject: nil] isKindOfClass: [OCSquirrelUserData class]],
                  @"Object returned by -newUserDataWithObject: method of OCSquirrelVM "
                  @"should be of OCSquirrelUserData class");
}


- (void)testOCSquirrelVMNewUserDataWithObjectHasImpl
{
    XCTAssertTrue([[_squirrelVM newUserDataWithObject: nil].impl isKindOfClass: [OCSquirrelUserDataImpl class]],
                  @"Object returned by -newUserDataWithObject: should have impl of OCSquirrelUserDataImpl class");
}


- (void)testOCSquirrelVMNewUserDataWithObjectBoundToVM
{
    XCTAssertEqualObjects([_squirrelVM newUserDataWithObject: nil].impl.squirrelVM, _squirrelVM,
                          @"Array returned by -newUserDataWithObject: should have be bound to the proper Squirrel VM");
}


#pragma mark - impl forwarding tests

- (void)testObjectIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelUserDataImpl class]];
    OCSquirrelUserData *userData = [[OCSquirrelUserData alloc] initWithImpl: implMock];
    
    [[implMock expect] object];
    
    [userData object];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelUserData should forward -call calls to its impl");
}


- (void)testSquirrelVMIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelUserDataImpl class]];
    OCSquirrelUserData *userData = [[OCSquirrelUserData alloc] initWithImpl: implMock];
    
    [[implMock expect] squirrelVM];
    
    [userData squirrelVM];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelUserData should forward -call calls to its impl");
}


- (void)testPushIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelUserDataImpl class]];
    OCSquirrelUserData *userData = [[OCSquirrelUserData alloc] initWithImpl: implMock];
    
    [[implMock expect] push];
    
    [userData push];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelUserData should forward -call calls to its impl");
}


- (void)testObjIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelUserDataImpl class]];
    OCSquirrelUserData *userData = [[OCSquirrelUserData alloc] initWithImpl: implMock];
    
    [[implMock expect] obj];
    
    [userData obj];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelUserData should forward -call calls to its impl");
}


- (void)testTypeIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelUserDataImpl class]];
    OCSquirrelUserData *userData = [[OCSquirrelUserData alloc] initWithImpl: implMock];
    
    [(OCSquirrelUserDataImpl *)[implMock expect] type];
    
    [userData type];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelUserData should forward -call calls to its impl");
}

@end
