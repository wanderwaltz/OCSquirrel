//
//  TestOCSquirrelArray.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 26.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#ifndef GHUnit_Target
    #import <XCTest/XCTest.h>
#endif

#import <OCSquirrel/OCSquirrel.h>

@interface TestOCSquirrelArray : XCTestCase
{
    OCSquirrelVM *_squirrelVM;
}

@end

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


#pragma mark - NSMutableArray integration tests

- (void)testIsKindOfArray
{
    XCTAssertTrue([[OCSquirrelArray new] isKindOfClass: [NSArray class]],
                  @"OCSquirrelArray should be kind of NSArray");
}


- (void)testKindOfMutableArray
{
    XCTAssertTrue([[OCSquirrelArray new] isKindOfClass: [NSMutableArray class]],
                  @"OCSquirrelArray should be kind of NSMutableArray");
}


- (void)testIsEqualToArray
{
    OCSquirrelArray *array = [OCSquirrelArray new];
    
    [array addObject: @1];
    [array addObject: @2];
    [array addObject: @3];
    
    XCTAssertEqualObjects(array, (@[@1, @2, @3]),
                          @"-isEqual: should be able to compare OCSquirrelArray with NSArray");
}


- (void)testRemoveObject
{
    OCSquirrelArray *array = [OCSquirrelArray new];
    
    [array addObject: @1];
    [array addObject: @2];
    [array addObject: @1];
    [array addObject: @3];
    [array addObject: @1];
    
    [array removeObject: @1];
    
    XCTAssertEqualObjects(array, (@[@2, @3]),
                          @"-removeObject: should remove all elements equal to the given object from the array");
}


- (void)testInitWithArrayClass
{
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithArray: @[@1, @2, @3]];
    
    XCTAssertTrue([array isKindOfClass: [OCSquirrelArray class]],
                  @"-initWithArray: should create instance of OCSquirrelArray");
}


- (void)testInitWithArray
{
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithArray: @[@1, @2, @3]];
    
    XCTAssertEqualObjects(array, (@[@1, @2, @3]),
                          @"-initWithArray: should populate created OCSquirrelArray with elements from the given NSArray");
}


- (void)testFastEnumeration
{
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithArray: @[@1, @2, @3]];
    
    NSMutableArray *enumerated = [NSMutableArray new];
    
    for (id element in array)
    {
        [enumerated addObject: element];
    }
    
    XCTAssertEqualObjects(array, enumerated,
                          @"OCSquirrelArray should support fast enumeration");
}


- (void)testNestedFastEnumeration
{
    OCSquirrelArray *first = [[OCSquirrelArray alloc] initWithArray: @[@1, @2, @3]];
    OCSquirrelArray *second = [[OCSquirrelArray alloc] initWithArray: @[@4, @5, @6]];
    
    NSMutableArray *firstEnumerated = [NSMutableArray new];
    NSMutableArray *secondEnumerated = [NSMutableArray new];
    
    for (id fi in first)
    {
        for (id si in second)
        {
            [firstEnumerated addObject: fi];
            [secondEnumerated addObject: si];
        }
    }
    
    XCTAssertEqualObjects((@[@1, @1, @1, @2, @2, @2, @3, @3, @3]), firstEnumerated, @"Nested enumeration should be possible");
    XCTAssertEqualObjects((@[@4, @5, @6, @4, @5, @6, @4, @5, @6]), secondEnumerated, @"Nested enumeration should be possible");
}


- (void)testNestedBlockEnumeration
{
    OCSquirrelArray *first = [[OCSquirrelArray alloc] initWithArray: @[@1, @2, @3]];
    OCSquirrelArray *second = [[OCSquirrelArray alloc] initWithArray: @[@4, @5, @6]];
    
    NSMutableArray *firstEnumerated = [NSMutableArray new];
    NSMutableArray *secondEnumerated = [NSMutableArray new];
    
    [first enumerateObjectsUsingBlock:^(id fo, NSInteger fi, BOOL *fs) {
        [second enumerateObjectsUsingBlock:^(id so, NSInteger si, BOOL *ss) {
            [firstEnumerated addObject: fo];
            [secondEnumerated addObject: so];
        }];
    }];
    
    XCTAssertEqualObjects((@[@1, @1, @1, @2, @2, @2, @3, @3, @3]), firstEnumerated, @"Nested enumeration should be possible");
    XCTAssertEqualObjects((@[@4, @5, @6, @4, @5, @6, @4, @5, @6]), secondEnumerated, @"Nested enumeration should be possible");
}


#pragma mark - <NSCopying> tests

- (void)testCopyClass
{
    OCSquirrelArray *array = [OCSquirrelArray new];
    OCSquirrelArray *clone = [array copy];
    
    XCTAssertTrue([clone isKindOfClass: [OCSquirrelArray class]],
                  @"Copying OCSquirrelArray should return an object of OCSquirrelArray class");
}


- (void)testCopySameVM
{
    OCSquirrelArray *array = [OCSquirrelArray new];
    OCSquirrelArray *clone = [array copy];
    
    XCTAssertEqualObjects(array.squirrelVM, clone.squirrelVM,
                          @"Copied OCSquirrelArray should be bound to the same SquirrelVM");
}


- (void)testCopyHasSameContents
{
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithArray: @[@1, @2, @3]];
    OCSquirrelArray *clone = [array copy];
    
    XCTAssertEqualObjects(array, clone,
                          @"Copied OCSquirrelArray should have the same contents");
}


- (void)testCopyIsDifferentArray
{
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithArray: @[@1, @2, @3]];
    OCSquirrelArray *clone = [array copy];
    
    [clone removeAllObjects];
    
    XCTAssertNotEqualObjects(array, clone,
                             @"Copied OCSquirrelArray should be a different mutable object");
}


- (void)testCopyIsShallow
{
    OCSquirrelTable *inner = [[OCSquirrelTable alloc] initWithDictionary: @{ @1 : @2, @3 : @4, @5 : @6 }];
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithObjects: inner, nil];
    
    OCSquirrelArray *clone = [array copy];
    OCSquirrelTable *clonedInner = clone.firstObject;
    
    [clonedInner removeObjectForKey: @1];
    
    XCTAssertEqualObjects(inner, clonedInner,
                          @"OCSquirrelArray copy is shallow and does not copy objects contained within the array");
}


@end
