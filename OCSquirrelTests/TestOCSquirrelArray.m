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

#ifndef GHUnit_Target
    #import <XCTest/XCTest.h>
#endif

#import <OCSquirrel/OCSquirrel.h>
#import "OCMock.h"

#pragma mark -
#pragma mark TestOCSquirrelArray interface

@interface TestOCSquirrelArray : XCTestCase
{
    OCSquirrelVM *_squirrelVM;
}

@end



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


#pragma mark -
#pragma mark objectAtIndex tests

- (void) testObjectForIntValueClass
{
    sq_newarray(_squirrelVM.vm, 0);
    
    HSQOBJECT sqArray = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    [_squirrelVM.stack pushInteger: 1234];
    
    sq_arrayappend(_squirrelVM.vm, -2);
    
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithHSQOBJECT: sqArray
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
    
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithHSQOBJECT: sqArray
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
    
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithHSQOBJECT: sqArray
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
    
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithHSQOBJECT: sqArray
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
    
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithHSQOBJECT: sqArray
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
    
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithHSQOBJECT: sqArray
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
    
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithHSQOBJECT: sqArray
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
    
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithHSQOBJECT: sqArray
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
    
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithHSQOBJECT: sqArray
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
    
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithHSQOBJECT: sqArray
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
    
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithHSQOBJECT: sqArray
                                                                   inVM: _squirrelVM];
    
    XCTAssertNil([array objectAtIndex: 0],
                 @"-objectAtIndex: should return nil for `null` value");
}


- (void) testObjectForUndefinedIndex
{
    sq_newarray(_squirrelVM.vm, 0);
    
    HSQOBJECT sqArray = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    [_squirrelVM.stack pushInteger: 1234];
    
    sq_arrayappend(_squirrelVM.vm, -2);
    
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithHSQOBJECT: sqArray
                                                                   inVM: _squirrelVM];
    
    XCTAssertNil([array objectAtIndex: 2],
                 @"-objectAtIndex: should return nil for index out of bounds");
}


#pragma mark -
#pragma mark indexed subscripting tests

- (void) testIndexedSubscriptCallsObjectAtIndex
{
    sq_newarray(_squirrelVM.vm, 0);
    
    HSQOBJECT sqArray = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    [_squirrelVM.stack pushInteger: 1234];
    
    sq_arrayappend(_squirrelVM.vm, -2);
    
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithHSQOBJECT: sqArray
                                                                   inVM: _squirrelVM];
    
    id arrayMock = [OCMockObject partialMockForObject: array];
    
    [[[arrayMock expect] andReturn: nil] objectAtIndex: 0];
    
    __unused id result = arrayMock[0];
    
    XCTAssertNoThrow([arrayMock verify], @"Indexed subscripting of OCSquirrelArray should call -objectAtIndex:");
}


#pragma mark -
#pragma mark enumeration

- (void) testEnumerateObjectsUsingBlock
{
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithVM: _squirrelVM];
    
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
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithVM: _squirrelVM];
    
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


@end
