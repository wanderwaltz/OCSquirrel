//
//  TestOCSquirrelUserData.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 01.06.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
    #error "This file should be compiled with ARC support"
#endif

#ifndef GHUnit_Target
#import <XCTest/XCTest.h>
#endif

#import <OCSquirrel/OCSquirrel.h>


@interface TestOCSquirrelUserData : XCTestCase
{
    OCSquirrelVM *_squirrelVM;
}
@end

@implementation TestOCSquirrelUserData

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


#pragma mark - tests

- (void)testInitWithObjectDefaultVM
{
    OCSquirrelUserData *ud = [[OCSquirrelUserData alloc] initWithObject: [NSNull null]];
    
    XCTAssertEqualObjects(ud.squirrelVM, [OCSquirrelVM defaultVM],
                          @"-initWithObject: should initialize OCSquirrelUserData with default Squirrel VM");
}


- (void)testInitWithObjectObject
{
    NSObject *object = [NSObject new];
    
    OCSquirrelUserData *ud = [[OCSquirrelUserData alloc] initWithObject: object];
    
    XCTAssertEqualObjects(ud.object, object,
                          @"-initWithObject: should set object property of OCSquirrelUserData");
}


- (void)testInitWithNilObject
{
    OCSquirrelUserData *ud = [[OCSquirrelUserData alloc] initWithObject: nil];
    
    XCTAssertNil(ud.object,
                 @"-initWithObject: OCSquirrelUserData should be able to be initialized with nil object");
}


- (void)testInitWithObjectRetainsObject
{
    NSObject *object = [NSObject new];
    
    NSInteger oldRetainCount = [[object valueForKey: @"retainCount"] integerValue];
    
    __unused OCSquirrelUserData *ud = [[OCSquirrelUserData alloc] initWithObject: object];
    
    NSInteger newRetainCount = [[object valueForKey: @"retainCount"] integerValue];
    
    XCTAssertEqual(newRetainCount, oldRetainCount+1,
                   @"-initWithObject: OCSquirrelUserData should retain object");
}


- (void)testReleasesObjectAtDealloc
{
    NSObject *object = [NSObject new];
    
    NSInteger oldRetainCount = [[object valueForKey: @"retainCount"] integerValue];
    
    @autoreleasepool {
        __unused OCSquirrelUserData *ud = [[OCSquirrelUserData alloc] initWithObject: object];
    }
    
    NSInteger newRetainCount = [[object valueForKey: @"retainCount"] integerValue];
    
    XCTAssertEqual(newRetainCount, oldRetainCount,
                   @"OCSquirrelUserData should release object after it is deallocated");
}


- (void)testInitWithObjectSquirrelVM
{
    OCSquirrelUserData *ud = [[OCSquirrelUserData alloc] initWithObject: nil
                                                           inSquirrelVM: _squirrelVM];
    
    XCTAssertEqualObjects(ud.squirrelVM, _squirrelVM,
                          @"-initWithObject:squirrelVM: should set squirrelVM property of OCSquirrelUserData");
}


- (void)testThrowsIfNilSquirrelVM
{
    XCTAssertThrowsSpecificNamed(({
        __unused OCSquirrelUserData *ud = [[OCSquirrelUserData alloc] initWithObject: nil
                                                                        inSquirrelVM: nil];
    }), NSException, NSInvalidArgumentException,
                                 @"-initWithObject:squirrelVM: should throw NSInvalidArgumentException if passed nil "
                                 @"as the Squirrel VM value");
}

@end
