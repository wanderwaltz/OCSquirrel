//
//  TestOCSquirrelArray+Protected.m
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
#import "OCMock.h"
#import "OCSquirrelVM+Protected.h"
#import "OCSquirrelArray+Protected.h"
#import "OCSquirrelArrayImpl.h"


@interface TestOCSquirrelArray_Protected : XCTestCase
{
    OCSquirrelVM *_squirrelVM;
}
@end

@implementation TestOCSquirrelArray_Protected

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
    OCSquirrelArrayImpl *impl = [[OCSquirrelArrayImpl alloc] initWithVM: _squirrelVM];
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithImpl: impl];
    
    XCTAssertEqualObjects(array.impl, impl, @"-initWithImpl: should set the impl property of OCSquirrelArray");
}


- (void)testOCSquirrelVMNewArrayClass
{
    XCTAssertTrue([[_squirrelVM newArray] isKindOfClass: [OCSquirrelArray class]],
                  @"Object returned by -newArray method of OCSquirrelVM should be of OCSquirrelArray class");
}


- (void)testOCSquirrelVMNewArrayWithObjectClass
{
    sq_newarray(_squirrelVM.vm, 0);
    
    HSQOBJECT sqArray = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    XCTAssertTrue([[_squirrelVM newArrayWithHSQObject: sqArray] isKindOfClass: [OCSquirrelArray class]],
                  @"Object returned by -newArrayWithHSQObject: should be of OCSquirrelArray class");
}


- (void)testOCSquirrelVMNewArrayHasImpl
{
    XCTAssertTrue([[_squirrelVM newArray].impl isKindOfClass: [OCSquirrelArrayImpl class]],
                  @"Object returned by -newArray should have impl of OCSquirrelArrayImpl class");
}


- (void)testOCSquirrelVMNewArrayWithObjectHasImpl
{
    sq_newarray(_squirrelVM.vm, 0);
    
    HSQOBJECT sqArray = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    XCTAssertTrue([[_squirrelVM newArrayWithHSQObject: sqArray].impl isKindOfClass: [OCSquirrelArrayImpl class]],
                  @"Object returned by -newArrayWithHSQObject: should have impl of OCSquirrelArrayImpl class");
}


- (void)testOCSquirrelVMNewArrayBoundToVM
{
    XCTAssertEqualObjects([_squirrelVM newArray].impl.squirrelVM, _squirrelVM,
                          @"Array returned by -newArray should have be bound to the proper Squirrel VM");
}


- (void)testOCSquirrelVMNewTableWithObjectBoundToVM
{
    sq_newarray(_squirrelVM.vm, 0);
    
    HSQOBJECT sqArray = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    XCTAssertEqualObjects([_squirrelVM newArrayWithHSQObject: sqArray].impl.squirrelVM, _squirrelVM,
                          @"Array returned by -newArrayWithHSQObject: should have be bound to the proper Squirrel VM");
}


#pragma mark - default initialization tests

- (void)testNewArrayHasImpl
{
    OCSquirrelArray *array = [OCSquirrelArray new];
    
    XCTAssertTrue([array.impl isKindOfClass: [OCSquirrelArrayImpl class]],
                  @"Newly created OCSquirrelArray should have impl of OCSquirrelArrayImpl class");
}


- (void)testNewArrayHasImplWithDefaultVM
{
    OCSquirrelArray *array = [OCSquirrelArray new];
    
    XCTAssertEqualObjects(array.impl.squirrelVM, [OCSquirrelVM defaultVM],
                          @"Newly created OCSquirrelArray should be bound to default OCSquirrelVM");
}


#pragma mark - impl forwarding tests

/*
 - (void)insertObject:(id)anObject atIndex:(NSInteger)index;
 - (void)removeObjectAtIndex:(NSInteger)index;
 
 - (id)pop;
 */

- (void)testCountIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelArrayImpl class]];
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithImpl: implMock];
    
    [[implMock expect] count];
    
    [array count];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelArray should forward -count calls to its impl");
}


- (void)testAddObjectIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelArrayImpl class]];
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithImpl: implMock];
    
    [[implMock expect] addObject: @1];
    
    [array addObject: @1];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelArray should forward -addObject: calls to its impl");
}


- (void)testObjectAtIndexIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelArrayImpl class]];
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithImpl: implMock];
    
    [[implMock expect] objectAtIndex: 1];
    
    [array objectAtIndex: 1];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelArray should forward -objectAtIndex: calls to its impl");
}


- (void)testObjectAtIndexedSubscriptIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelArrayImpl class]];
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithImpl: implMock];
    
    [[implMock expect] objectAtIndexedSubscript: 1];
    
    __unused id result = array[1];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelArray should forward -objectAtIndexedSubscript: calls to its impl");
}


- (void)testEnumerateObjectsUsingBlockIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelArrayImpl class]];
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithImpl: implMock];
    
    [[implMock expect] enumerateObjectsUsingBlock: OCMOCK_ANY];
    
    [array enumerateObjectsUsingBlock:^(id object, NSInteger index, BOOL *stop) {
        
    }];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelArray should forward -enumerateObjectsUsingBlock: calls to its impl");
}


- (void)testSetObjectAtIndexIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelArrayImpl class]];
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithImpl: implMock];
    
    [[implMock expect] setObject: @1 atIndex: 1];
    
    [array setObject: @1 atIndex: 1];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelArray should forward -setObject:atIndex: calls to its impl");
}


- (void)testSetObjectAtIndexedSubscriptIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelArrayImpl class]];
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithImpl: implMock];
    
    [[implMock expect] setObject: @1 atIndexedSubscript: 1];
    
    array[1] = @1;
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelArray should forward -setObject:atIndexedSubscript: calls to its impl");
}


- (void)testInsertObjectAtIndexIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelArrayImpl class]];
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithImpl: implMock];
    
    [[implMock expect] insertObject: @1 atIndex: 1];
    
    [array insertObject: @1 atIndex: 1];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelArray should forward -insertObject:atIndex: calls to its impl");
}


- (void)testRemoveObjectAtIndexIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelArrayImpl class]];
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithImpl: implMock];
    
    [[implMock expect] removeObjectAtIndex: 1];
    
    [array removeObjectAtIndex: 1];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelArray should forward -removeObjectAtIndex: calls to its impl");
}


- (void)testPopIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelArrayImpl class]];
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithImpl: implMock];
    
    [[implMock expect] pop];
    
    [array pop];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelArray should forward -pop calls to its impl");
}


- (void)testSquirrelVMIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelArrayImpl class]];
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithImpl: implMock];
    
    [[implMock expect] squirrelVM];
    
    [array squirrelVM];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelArray should forward -squirrelVM calls to its impl");
}


- (void)testPushIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelArrayImpl class]];
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithImpl: implMock];
    
    [[implMock expect] push];
    
    [array push];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelArray should forward -push calls to its impl");
}


- (void)testObjIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelArrayImpl class]];
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithImpl: implMock];
    
    [[implMock expect] obj];
    
    [array obj];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelArray should forward -obj calls to its impl");
}


- (void)testTypeIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelArrayImpl class]];
    OCSquirrelArray *array = [[OCSquirrelArray alloc] initWithImpl: implMock];
    
    [(OCSquirrelArrayImpl *)[implMock expect] type];
    
    [array type];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelArray should forward -type calls to its impl");
}


@end
