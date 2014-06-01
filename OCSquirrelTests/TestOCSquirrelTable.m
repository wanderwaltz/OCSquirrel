//
//  TestOCSquirrelTable.m
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

@interface TestOCSquirrelTable : XCTestCase
{
    OCSquirrelVM *_squirrelVM;   
}
@end

@implementation TestOCSquirrelTable

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


#pragma mark - initialization tests

- (void)testInitWithVM
{
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithVM: _squirrelVM];
    
    XCTAssertEqualObjects(table.squirrelVM, _squirrelVM,
                          @"OCSquirrelTable should store the squirrelVM property value");
}


- (void)testThrowsInitWithNilVM
{
    XCTAssertThrowsSpecificNamed(({
        __unused OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithVM: nil];
    }), NSException, NSInvalidArgumentException,
                                 @"OCSquirrelTable should throw NSInvalidArgumentException when trying to initialize "
                                 @"with nil Squirrel VM.");
}


#pragma mark - NSMutableDictionary integration tests

- (void)testKindOfDictionary
{
    OCSquirrelTable *table = [OCSquirrelTable new];
    
    XCTAssertTrue([table isKindOfClass: [NSDictionary class]],
                  @"OCSquirrelTable should be kind of NSDictionary");
}


- (void)testKindOfMutableDictionary
{
    OCSquirrelTable *table = [OCSquirrelTable new];
    
    XCTAssertTrue([table isKindOfClass: [NSMutableDictionary class]],
                  @"OCSquirrelTable should be kind of NSMutableDictionary");
}


- (void)testInitiallyEmpty
{
    OCSquirrelTable *table = [OCSquirrelTable new];
    
    XCTAssertEqual(table.count, (NSUInteger)0, @"Initial count of OCSquirrelTable should be equal to 0");
}


- (void)testEqualToDictionary
{
    OCSquirrelTable *table = [OCSquirrelTable new];
    
    table[@1] = @2;
    table[@3] = @4;
    table[@5] = @6;
    
    XCTAssertEqualObjects(table, (@{ @1 : @2, @3 : @4, @5 : @6 }),
                          @"-isEqual: should be able to compate OCSquirrelTable and NSDictionary");
}


- (void)testAllKeys
{
    OCSquirrelTable *table = [OCSquirrelTable new];
    
    table[@1] = @2;
    table[@3] = @4;
    table[@5] = @6;
    
    NSSet *keysSet = [NSSet setWithObjects: @1, @3, @5, nil];
    NSSet *tableKeysSet = [NSSet setWithArray: table.allKeys];
    
    XCTAssertEqualObjects(tableKeysSet, keysSet,
                          @"-allKeys should return all keys of the table");
}


- (void)testAllValues
{
    OCSquirrelTable *table = [OCSquirrelTable new];
    
    table[@1] = @2;
    table[@3] = @4;
    table[@5] = @6;
    
    NSSet *valuesSet = [NSSet setWithObjects: @2, @4, @6, nil];
    NSSet *tableValuesSet = [NSSet setWithArray: table.allValues];
    
    XCTAssertEqualObjects(tableValuesSet, valuesSet,
                          @"-allValues should return all values of the table");
}


- (void)testInitWithDictionary
{
    NSDictionary *dictionary = @{ @1 : @2, @3 : @4, @5 : @6 };
    
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithDictionary: dictionary];
    
    XCTAssertEqualObjects(table, dictionary,
                          @"-initWithDictionary: should init the OCSquirrelTable with the given dictionary");
}


- (void)testInitWithDictionaryClass
{
    NSDictionary *dictionary = @{ @1 : @2, @3 : @4, @5 : @6 };
    
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithDictionary: dictionary];
    
    XCTAssertTrue([table isKindOfClass: [OCSquirrelTable class]],
                  @"-initWithDictionary: should create instance of OCSquirrelTable class");
}


- (void)testRemoveAllObjects
{
    OCSquirrelTable *table = [OCSquirrelTable new];
    
    table[@1] = @2;
    table[@3] = @4;
    table[@5] = @6;
    
    [table removeAllObjects];
    
    XCTAssertEqual(table.count, (NSUInteger)0,
                   @"-removeAllObjects should remove all objects from OCSquirrelTable");
}


- (void)testRemoveObjectsForKeys
{
    OCSquirrelTable *table = [OCSquirrelTable new];
    
    table[@1] = @2;
    table[@3] = @4;
    table[@5] = @6;
    
    [table removeObjectsForKeys: @[@1, @3]];
    
    XCTAssertEqualObjects(table, @{ @5 : @6 },
                   @"-removeObjectsForKeys should remove corresponding objects from OCSquirrelTable");
}


#pragma mark - <NSCopying> tests

- (void)testCopyClass
{
    OCSquirrelTable *table = [OCSquirrelTable new];
    OCSquirrelTable *clone = [table copy];
    
    XCTAssertTrue([clone isKindOfClass: [OCSquirrelTable class]],
                  @"Copying OCSquirrelTable should return an object of OCSquirrelTable class");
}


- (void)testCopySameVM
{
    OCSquirrelTable *table = [OCSquirrelTable new];
    OCSquirrelTable *clone = [table copy];
    
    XCTAssertEqualObjects(table.squirrelVM, clone.squirrelVM,
                          @"Copied OCSquirrelTable should be bound to the same SquirrelVM");
}


- (void)testCopyHasSameContents
{
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithDictionary: @{ @1 : @2, @3 : @4, @5 : @6 }];
    OCSquirrelTable *clone = [table copy];
    
    XCTAssertEqualObjects(table, clone,
                          @"Copied OCSquirrelTable should have the same contents");
}


- (void)testCopyIsDifferentTable
{
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithDictionary: @{ @1 : @2, @3 : @4, @5 : @6 }];
    OCSquirrelTable *clone = [table copy];
    
    [clone removeAllObjects];
    
    XCTAssertNotEqualObjects(table, clone,
                             @"Copied OCSquirrelTable should be a different mutable object");
}


- (void)testCopyIsShallow
{
    OCSquirrelTable *inner = [[OCSquirrelTable alloc] initWithDictionary: @{ @1 : @2, @3 : @4, @5 : @6 }];
    OCSquirrelTable *table = [OCSquirrelTable new];
    table[@"inner"] = inner;
    
    OCSquirrelTable *clone = [table copy];
    OCSquirrelTable *clonedInner = clone[@"inner"];
    
    [clonedInner removeObjectForKey: @1];
    
    XCTAssertEqualObjects(inner, clonedInner,
                          @"OCSquirrelTable copy is shallow and does not copy objects contained within the table");
}


#pragma mark - other tests

- (void)testThrowsWhenSettingValueBoundToOtherVM
{
    // Table is bound to [OCSquirrelVM defaultVM] which differs from _squrrelVM
    OCSquirrelTable *table = [OCSquirrelTable new];
    
    XCTAssertThrowsSpecificNamed(table[@"key"] = [_squirrelVM rootTable],
                                 NSException, NSInvalidArgumentException,
                                 @"OCSquirrelTable should throw an NSInvalidArgumentException when trying to set "
                                 @"an OCSquirrelObject bound to another Squirrel VM as a value");
    
}

@end
