//
//  TestOCSquirrelArray.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 6/10/13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "TestOCSquirrelArray.h"


#pragma mark -
#pragma mark TestOCSquirrelArray implementation

@implementation TestOCSquirrelArray

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


#pragma mark -
#pragma mark basic tests

- (void) testOCSquirrelArrayClassExists
{
    XCTAssertTrue([OCSquirrelArray isSubclassOfClass: [OCSquirrelObject class]],
                 @"OCSquirrelArray class should exist and be a subclass of OCSquirrelObject");
}


- (void) testNewArrayInitializingWithVM
{
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithVM: _squirrelVM];
    
    XCTAssertNotNil(array, @"Should be able to create OCSquirrelArray instances");
}


- (void) testTypeAfterInitializingWithVM
{
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithVM: _squirrelVM];
    
    XCTAssertEqual(array.type, OT_ARRAY,
                   @"OCSquirrelArray should be a wrapper for OT_ARRAY HSQOBJECT");
}


- (void) testNewEmptyArrayCount
{
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithVM: _squirrelVM];
    
    XCTAssertEqual((NSUInteger)array.count, (NSUInteger)0,
                   @"Number of elements should be zero after creating a new empty array.");
}


- (void) testCountAfterAddingElement
{
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithVM: _squirrelVM];
    
    [array addObject: @123];
    
    XCTAssertEqual((NSUInteger)array.count, (NSUInteger)1,
                   @"Number of elements should be 1 after inserting an object into empty array");
    
}


@end
