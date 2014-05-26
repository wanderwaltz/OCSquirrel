//
//  TestOCSquirrelArrayImpl.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 6/10/13.
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
#import "OCSquirrelArrayImpl.h"
#import "OCMock.h"

#pragma mark -
#pragma mark TestOCSquirrelArrayImpl interface

@interface TestOCSquirrelArrayImpl : XCTestCase
{
    OCSquirrelVM *_squirrelVM;
}

@end



#pragma mark -
#pragma mark TestOCSquirrelArrayImpl implementation

@implementation TestOCSquirrelArrayImpl

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

- (void) testOCSquirrelArrayImplClassExists
{
    XCTAssertTrue([OCSquirrelArrayImpl isSubclassOfClass: [OCSquirrelObject class]],
                 @"OCSquirrelArrayImpl class should exist and be a subclass of OCSquirrelObject");
}


- (void) testNewArrayInitializingWithVM
{
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithVM: _squirrelVM];
    
    XCTAssertNotNil(array, @"Should be able to create OCSquirrelArrayImpl instances");
}


- (void) testTypeAfterInitializingWithVM
{
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithVM: _squirrelVM];
    
    XCTAssertEqual(array.type, OT_ARRAY,
                   @"OCSquirrelArrayImpl should be a wrapper for OT_ARRAY HSQOBJECT");
}


- (void) testNewEmptyArrayCount
{
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithVM: _squirrelVM];
    
    XCTAssertEqual((NSUInteger)array.count, (NSUInteger)0,
                   @"Number of elements should be zero after creating a new empty array.");
}


- (void) testCountAfterAddingElement
{
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithVM: _squirrelVM];
    
    [array addObject: @123];
    
    XCTAssertEqual((NSUInteger)array.count, (NSUInteger)1,
                   @"Number of elements should be 1 after inserting an object into empty array");
    
}


#pragma mark -
#pragma mark objectAtIndex tests

- (void) testObjectForIntValueClass
{
    sq_newarray(_squirrelVM.vm, 0);
    
    HSQOBJECT sqArray = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    [_squirrelVM.stack pushInteger: 1234];
    
    sq_arrayappend(_squirrelVM.vm, -2);
    
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithHSQOBJECT: sqArray
                                                                   inVM: _squirrelVM];
    
    XCTAssertTrue([[array objectAtIndex: 0] isKindOfClass: [NSNumber class]],
                  @"-objectAtIndex: should return an NSNumber for integer value");
}


- (void) testObjectForIntValueValue
{
    sq_newarray(_squirrelVM.vm, 0);
    
    HSQOBJECT sqArray = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    [_squirrelVM.stack pushInteger: 1234];
    
    sq_arrayappend(_squirrelVM.vm, -2);
    
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithHSQOBJECT: sqArray
                                                                   inVM: _squirrelVM];
    
    XCTAssertEqual((NSInteger)[[array objectAtIndex: 0] integerValue], (NSInteger)1234,
                   @"-objectAtIndex: should return the appropriate NSNumber for integer value");
}


- (void) testObjectForFloatValueClass
{
    sq_newarray(_squirrelVM.vm, 0);
    
    HSQOBJECT sqArray = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    [_squirrelVM.stack pushFloat: 123.456];
    
    sq_arrayappend(_squirrelVM.vm, -2);
    
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithHSQOBJECT: sqArray
                                                                   inVM: _squirrelVM];
    
    XCTAssertTrue([[array objectAtIndex: 0] isKindOfClass: [NSNumber class]],
                  @"-objectAtIndex: should return an NSNumber for float value");
}


- (void) testObjectForFloatValueValue
{
    sq_newarray(_squirrelVM.vm, 0);
    
    HSQOBJECT sqArray = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    [_squirrelVM.stack pushFloat: 123.456];
    
    sq_arrayappend(_squirrelVM.vm, -2);
    
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithHSQOBJECT: sqArray
                                                                   inVM: _squirrelVM];
    
    XCTAssertEqual([[array objectAtIndex: 0] floatValue], 123.456f,
                   @"-objectAtIndex: should return the appropriate NSNumber for float value");
}


- (void) testObjectForBoolValueClass
{
    sq_newarray(_squirrelVM.vm, 0);
    
    HSQOBJECT sqArray = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    [_squirrelVM.stack pushBool: YES];
    
    sq_arrayappend(_squirrelVM.vm, -2);
    
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithHSQOBJECT: sqArray
                                                                   inVM: _squirrelVM];
    
    XCTAssertTrue([[array objectAtIndex: 0] isKindOfClass: [NSNumber class]],
                  @"-objectAtIndex: should return an NSNumber for BOOL value");
}


- (void) testObjectForBoolValueValue
{
    sq_newarray(_squirrelVM.vm, 0);
    
    HSQOBJECT sqArray = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    [_squirrelVM.stack pushBool: YES];
    
    sq_arrayappend(_squirrelVM.vm, -2);
    
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithHSQOBJECT: sqArray
                                                                   inVM: _squirrelVM];
    
    XCTAssertEqual([[array objectAtIndex: 0] boolValue], YES,
                   @"-objectAtIndex: should return the appropriate NSNumber for BOOL value");
}


- (void) testObjectForStringValueClass
{
    sq_newarray(_squirrelVM.vm, 0);
    
    HSQOBJECT sqArray = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    [_squirrelVM.stack pushString: @"someValue"];
    
    sq_arrayappend(_squirrelVM.vm, -2);
    
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithHSQOBJECT: sqArray
                                                                   inVM: _squirrelVM];
    
    XCTAssertTrue([[array objectAtIndex: 0] isKindOfClass: [NSString class]],
                  @"-objectAtIndex: should return an NSString for string value");
}


- (void) testObjectForStringValueValue
{
    sq_newarray(_squirrelVM.vm, 0);
    
    HSQOBJECT sqArray = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    [_squirrelVM.stack pushString: @"someValue"];
    
    sq_arrayappend(_squirrelVM.vm, -2);
    
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithHSQOBJECT: sqArray
                                                                   inVM: _squirrelVM];
    
    XCTAssertEqualObjects([array objectAtIndex: 0], @"someValue",
                          @"-objectAtIndex: should return the appropriate NSString for string value");
}


- (void) testObjectForUserPointerValueClass
{
    sq_newarray(_squirrelVM.vm, 0);
    
    HSQOBJECT sqArray = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    [_squirrelVM.stack pushUserPointer: (__bridge SQUserPointer)self];
    
    sq_arrayappend(_squirrelVM.vm, -2);
    
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithHSQOBJECT: sqArray
                                                                   inVM: _squirrelVM];
    
    XCTAssertTrue([[array objectAtIndex: 0] isKindOfClass: [NSValue class]],
                  @"-objectAtIndex: should return an NSValue for userPointer value");
}


- (void) testObjectForUserPointerValueValue
{
    sq_newarray(_squirrelVM.vm, 0);
    
    HSQOBJECT sqArray = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    [_squirrelVM.stack pushUserPointer: (__bridge SQUserPointer)self];
    
    sq_arrayappend(_squirrelVM.vm, -2);
    
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithHSQOBJECT: sqArray
                                                                   inVM: _squirrelVM];
    
    XCTAssertEqual([[array objectAtIndex: 0] pointerValue], (__bridge void *)self,
                   @"-objectAtIndex: should return the appropriate NSValue for userPointer value");
}


- (void) testObjectForNullValue
{
    sq_newarray(_squirrelVM.vm, 0);
    
    HSQOBJECT sqArray = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    [_squirrelVM.stack pushNull];
    
    sq_arrayappend(_squirrelVM.vm, -2);
    
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithHSQOBJECT: sqArray
                                                                   inVM: _squirrelVM];
    
    XCTAssertNil([array objectAtIndex: 0],
                 @"-objectAtIndex: should return nil for `null` value");
}


#pragma mark -
#pragma mark indexed subscripting tests

- (void) testIndexedSubscriptCallsObjectAtIndex
{
    sq_newarray(_squirrelVM.vm, 0);
    
    HSQOBJECT sqArray = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    [_squirrelVM.stack pushInteger: 1234];
    
    sq_arrayappend(_squirrelVM.vm, -2);
    
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithHSQOBJECT: sqArray
                                                                   inVM: _squirrelVM];
    
    id arrayMock = [OCMockObject partialMockForObject: array];
    
    [[[arrayMock expect] andReturn: nil] objectAtIndex: 0];
    
    __unused id result = arrayMock[0];
    
    XCTAssertNoThrow([arrayMock verify], @"Indexed subscripting of OCSquirrelArrayImpl should call -objectAtIndex:");
}


- (void) testSetObjectForIndexedSubscriptCallsSetObjectAtIndex
{
    sq_newarray(_squirrelVM.vm, 0);
    
    HSQOBJECT sqArray = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    [_squirrelVM.stack pushInteger: 1234];
    
    sq_arrayappend(_squirrelVM.vm, -2);
    
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithHSQOBJECT: sqArray
                                                                   inVM: _squirrelVM];
    
    id arrayMock = [OCMockObject partialMockForObject: array];
    
    [[arrayMock expect] setObject: [NSNull null] atIndex: 2];
    
    array[2] = [NSNull null];
    
    XCTAssertNoThrow([arrayMock verify],
                     @"Setting object using indexed subscripting of OCSquirrelArrayImpl "
                     @"should call -setObject:atIndex:");
}


#pragma mark -
#pragma mark enumeration

- (void) testEnumerateObjectsUsingBlock
{
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithVM: _squirrelVM];
    
    NSArray *values = @[@1, @2, @3];
    
    [array addObject: @1];
    [array addObject: @2];
    [array addObject: @3];
    
    NSMutableArray *enumerated = [NSMutableArray new];
    
    __block NSInteger iteration = 0;
    
    [array enumerateObjectsUsingBlock:
     ^(id object, NSInteger index, BOOL *stop) {
         [enumerated addObject: object];
         
         XCTAssertEqual(iteration, index, @"-enumerateObjectsUsingBlock: should properly enumerate indexes");
         
         iteration++;
    }];
    
    XCTAssertEqualObjects(values, enumerated,
                          @"-enumerateObjectsUsingBlock should enumerate all array elements");
}


- (void) testEnumerateObjectsUsingBlockStop
{
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithVM: _squirrelVM];
    
    [array addObject: @1];
    [array addObject: @2];
    [array addObject: @3];
    
    __block NSInteger iterations = 0;
    
    [array enumerateObjectsUsingBlock:
     ^(id object, NSInteger index, BOOL *stop) {
         iterations++;
         *stop = YES;
     }];
    
    XCTAssertEqual((NSUInteger)iterations, (NSUInteger)1,
                   @"-enumerateObjectsUsingBlock should stop if stop parameter of the block is "
                   @"set to YES");
}


#pragma mark -
#pragma mark generic setter tests

- (void) testSetObjectIntAtIndexOnce
{
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithVM: _squirrelVM];
    
    [array addObject: @1234];
    
    [array setObject: @5678 atIndex: 0];
    
    XCTAssertEqualObjects([array objectAtIndex: 0], @5678,
                          @"Integer value should be properly set by setObject:atIndex:");
}


- (void) testSetObjectFloatAtIndex
{
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithVM: _squirrelVM];
    
    [array addObject: @1234];
    
    [array setObject: @123.456 atIndex: 0];
    
    XCTAssertEqualObjects([array objectAtIndex: 0], @123.456,
                          @"Float value should be properly set by setObject:atIndex:");
}


- (void) testSetObjectBoolAtIndex
{
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithVM: _squirrelVM];
    
    [array addObject: @1234];
    
    [array setObject: @YES atIndex: 0];
    
    XCTAssertEqualObjects([array objectAtIndex: 0], @YES,
                          @"Bool value should be properly set by setObject:atIndex:");
}


- (void) testSetObjectUserPointerAtIndex
{
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithVM: _squirrelVM];
    
    [array addObject: @1234];
    
    [array setObject: [NSValue valueWithPointer: (__bridge void *)self] atIndex: 0];
    
    XCTAssertEqualObjects([array objectAtIndex: 0], [NSValue valueWithPointer: (__bridge void *)self],
                          @"UserPoniter value should be properly set by setObject:atIndex:");
}


- (void) testSetObjectStringAtIndex
{
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithVM: _squirrelVM];
    
    [array addObject: @1234];
    
    [array setObject: @"someValue" atIndex: 0];
    
    XCTAssertEqualObjects([array objectAtIndex: 0], @"someValue",
                          @"String value should be properly set by setObject:atIndex:");
}


- (void) testSetObjectNilAtIndex
{
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithVM: _squirrelVM];
    
    [array addObject: @1234];
    
    [array setObject: nil atIndex: 0];
    
    XCTAssertNil([array objectAtIndex: 0],
                 @"nil value should be properly set by setObject:atIndex:");
}


#pragma mark - insertion/removal tests

- (void)testInsertObjectIntoEmptyArrayCount
{
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithVM: _squirrelVM];
    
    [array insertObject: @1 atIndex: 0];
    
    XCTAssertEqual(array.count, (NSUInteger)1,
                   @"-count should be equal to 1 after inserting an object into empty array at index 0");
}


- (void)testInsertObjectIntoEmptyArrayValue
{
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithVM: _squirrelVM];
    
    [array insertObject: @1 atIndex: 0];
    
    XCTAssertEqualObjects(array[0], @1,
                          @"-insertObject:atIndex: should properly insert object into empty array");
}


- (void)testInsertObjectZeroIndex
{
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithVM: _squirrelVM];
    
    [array insertObject: @1 atIndex: 0];
    [array insertObject: @2 atIndex: 0];
    [array insertObject: @3 atIndex: 0];
    
    XCTAssertEqualObjects(array[0], @3,
                          @"-insertObject:atIndex: should properly insert object at zero index");
    XCTAssertEqualObjects(array[1], @2,
                          @"-insertObject:atIndex: should properly insert object at zero index");
    XCTAssertEqualObjects(array[2], @1,
                          @"-insertObject:atIndex: should properly insert object at zero index");
}


- (void)testInsertObjectVariousIndexes
{
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithVM: _squirrelVM];
    
    [array insertObject: @1 atIndex: 0];
    [array insertObject: @2 atIndex: 1];
    [array insertObject: @3 atIndex: 0];
    
    XCTAssertEqualObjects(array[0], @3,
                          @"-insertObject:atIndex: should properly insert object at zero index");
    XCTAssertEqualObjects(array[1], @1,
                          @"-insertObject:atIndex: should properly insert object at zero index");
    XCTAssertEqualObjects(array[2], @2,
                          @"-insertObject:atIndex: should properly insert object at zero index");
}


- (void)testPopReturnValue
{
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithVM: _squirrelVM];
    
    [array insertObject: @1 atIndex: 0];
    [array insertObject: @2 atIndex: 0];
    
    id popped = [array pop];
    
    XCTAssertEqualObjects(popped, @1,
                          @"-pop should return last object of the array");
}


- (void)testPopCount
{
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithVM: _squirrelVM];
    
    [array insertObject: @1 atIndex: 0];
    [array insertObject: @2 atIndex: 0];
    
    [array pop];
    
    XCTAssertEqual(array.count, (NSUInteger)1,
                   @"-pop should remove an element from the array");
}


- (void)testPopRemoval
{
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithVM: _squirrelVM];
    
    [array insertObject: @1 atIndex: 0];
    [array insertObject: @2 atIndex: 0];
    
    [array pop];
    
    XCTAssertEqualObjects(array[0], @2,
                          @"-pop should remove an element from the array");
}


- (void)testRemoveObjectAtIndexCount
{
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithVM: _squirrelVM];
    
    [array insertObject: @1 atIndex: 0];
    [array insertObject: @2 atIndex: 0];
    [array insertObject: @3 atIndex: 0];
    
    [array removeObjectAtIndex: 1];
    
    XCTAssertEqual(array.count, (NSUInteger)2,
                   @"-removeObjectAtIndex: should remove an element from the array");
}


- (void)testRemoveObjectAtIndexValues
{
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithVM: _squirrelVM];
    
    [array insertObject: @1 atIndex: 0];
    [array insertObject: @2 atIndex: 0];
    [array insertObject: @3 atIndex: 0];
    
    [array removeObjectAtIndex: 1];
    
    XCTAssertEqualObjects(array[0], @3,
                          @"-removeObjectAtIndex: should remove an element from the array");
    XCTAssertEqualObjects(array[1], @1,
                          @"-removeObjectAtIndex: should remove an element from the array");
}


#pragma mark - exceptions tests

- (void)testObjectAtIndexUpperBoundException
{
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithVM: _squirrelVM];
    
    [array insertObject: @1 atIndex: 0];
    [array insertObject: @2 atIndex: 1];
    [array insertObject: @3 atIndex: 0];
    
    XCTAssertThrowsSpecificNamed([array objectAtIndex: 3], NSException, NSRangeException,
                                 @"-objectAtIndex: should throw an NSRangeException if "
                                 @"index is >= array.count");
}


- (void)testObjectAtIndexLowerBoundException
{
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithVM: _squirrelVM];
    
    [array insertObject: @1 atIndex: 0];
    [array insertObject: @2 atIndex: 1];
    [array insertObject: @3 atIndex: 0];
    
    XCTAssertThrowsSpecificNamed([array objectAtIndex: -4], NSException, NSRangeException,
                                 @"-objectAtIndex: should throw an NSRangeException if "
                                 @"index is < -array.count");
}


- (void)testSetObjectAtIndexUpperBoundException
{
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithVM: _squirrelVM];
    
    [array insertObject: @1 atIndex: 0];
    [array insertObject: @2 atIndex: 1];
    [array insertObject: @3 atIndex: 0];
    
    XCTAssertThrowsSpecificNamed([array setObject: @4 atIndex: 3], NSException, NSRangeException,
                                 @"-setObject:atIndex: should throw an NSRangeException if "
                                 @"index is >= array.count");
}


- (void)testSetObjectAtIndexLowerBoundException
{
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithVM: _squirrelVM];
    
    [array insertObject: @1 atIndex: 0];
    [array insertObject: @2 atIndex: 1];
    [array insertObject: @3 atIndex: 0];
    
    XCTAssertThrowsSpecificNamed([array setObject: @4 atIndex: -4], NSException, NSRangeException,
                                 @"-setObject:atIndex: should throw an NSRangeException if "
                                 @"index is < -array.count");
}


- (void)testInsertObjectAtIndexOutOfBoundsThrowsNSRangeException
{
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithVM: _squirrelVM];
    
    [array insertObject: @1 atIndex: 0];
    [array insertObject: @2 atIndex: 1];
    [array insertObject: @3 atIndex: 0];
    
    XCTAssertThrowsSpecificNamed([array insertObject: @16 atIndex: 16], NSException, NSRangeException,
                                 @"-insertObject:atIndex: should throw an NSRangeException if "
                                 @"index is out of array's bounds");
}


- (void)testPopFromEmptyArrayThrowsNSRangeException
{
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithVM: _squirrelVM];
    
    XCTAssertThrowsSpecificNamed([array pop], NSException, NSRangeException,
                                 @"-pop should throw an NSRangeException if there are no objects in array");
}


- (void)testRemoveObjectAtIndexOutOfBoundsThrowsNSRangeException
{
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithVM: _squirrelVM];
    
    [array insertObject: @1 atIndex: 0];
    [array insertObject: @2 atIndex: 0];
    [array insertObject: @3 atIndex: 0];
    
    XCTAssertThrowsSpecificNamed([array removeObjectAtIndex: 16], NSException, NSRangeException,
                                 @"-removeObjectAtIndex: should throw an NSRangeException if "
                                 @"index is out of array's bounds");
}


#pragma mark - negative indices tests

- (void)testObjectAtNegativeIndex
{
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithVM: _squirrelVM];
    
    [array insertObject: @1 atIndex: 0];
    [array insertObject: @2 atIndex: 0];
    [array insertObject: @3 atIndex: 0];
    
    XCTAssertEqualObjects([array objectAtIndex: -1], @1,
                          @"-objectAtIndex: should wrap around for negative indices");
}


- (void)testSetObjectAtNegativeIndex
{
    OCSquirrelArrayImpl *array = [[OCSquirrelArrayImpl alloc] initWithVM: _squirrelVM];
    
    [array insertObject: @1 atIndex: 0];
    [array insertObject: @2 atIndex: 0];
    [array insertObject: @3 atIndex: 0];
    
    [array setObject: @4 atIndex: -1];
    
    XCTAssertEqualObjects([array objectAtIndex: 2], @4,
                          @"-setObject:atIndex: should wrap around for negative indices");
}


@end
