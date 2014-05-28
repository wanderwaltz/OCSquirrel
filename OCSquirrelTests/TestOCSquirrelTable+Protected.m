//
//  TestOCSquirrelTable+Protected.m
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
#import "OCSquirrelTable+Protected.h"

@interface TestOCSquirrelTable_Protected : XCTestCase
{
    OCSquirrelVM *_squirrelVM;
}

@end


@implementation TestOCSquirrelTable_Protected

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
    OCSquirrelTableImpl *impl = [[OCSquirrelTableImpl alloc] initWithVM: _squirrelVM];
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithImpl: impl];
    
    XCTAssertEqualObjects(table.impl, impl, @"-initWithImpl: should set the impl property of OCSquirrelTable");
}


- (void)testOCSquirrelVMRootTableClass
{
    XCTAssertTrue([[_squirrelVM rootTable] isKindOfClass: [OCSquirrelTable class]],
                  @"Object returned by -rootTable method of OCSquirrelVM should be of OCSquirrelTable class");
}


- (void)testOCSquirrelVMRegistryTableClass
{
    XCTAssertTrue([[_squirrelVM registryTable] isKindOfClass: [OCSquirrelTable class]],
                  @"Object returned by -registryTable method of OCSquirrelVM should be of OCSquirrelTable class");
}


- (void)testOCSquirrelVMNewTableClass
{
    XCTAssertTrue([[_squirrelVM newTable] isKindOfClass: [OCSquirrelTable class]],
                  @"Object returned by -newTable method of OCSquirrelVM should be of OCSquirrelTable class");
}


- (void)testOCSquirrelVMNewTableWithObjectClass
{
    sq_pushroottable(_squirrelVM.vm);
    
    HSQOBJECT root = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    XCTAssertTrue([[_squirrelVM newTableWithHSQObject: root] isKindOfClass: [OCSquirrelTable class]],
                  @"Object returned by -newTableWithHSQObject: should be of OCSquirrelTable class");
}


- (void)testOCSquirrelVMRootTableHasImpl
{
    XCTAssertTrue([[_squirrelVM rootTable].impl isKindOfClass: [OCSquirrelTableImpl class]],
                  @"Object returned by -rootTable should have impl of OCSquirrelTableImpl class");
}


- (void)testOCSquirrelVMRegistryTableHasImpl
{
    XCTAssertTrue([[_squirrelVM registryTable].impl isKindOfClass: [OCSquirrelTableImpl class]],
                  @"Object returned by -registryTable should have impl of OCSquirrelTableImpl class");
}


- (void)testOCSquirrelVMNewTableHasImpl
{
    XCTAssertTrue([[_squirrelVM newTable].impl isKindOfClass: [OCSquirrelTableImpl class]],
                  @"Object returned by -newTable should have impl of OCSquirrelTableImpl class");
}


- (void)testOCSquirrelVMNewTableWithObjectHasImpl
{
    sq_pushroottable(_squirrelVM.vm);
    
    HSQOBJECT root = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    XCTAssertTrue([[_squirrelVM newTableWithHSQObject: root].impl isKindOfClass: [OCSquirrelTableImpl class]],
                  @"Object returned by -newTableWithHSQObject: should have impl of OCSquirrelTableImpl class");
}


- (void)testOCSquirrelVMRootTableBoundToVM
{
    XCTAssertEqualObjects([_squirrelVM rootTable].impl.squirrelVM, _squirrelVM,
                          @"Table returned by -rootTable should have be bound to the proper Squirrel VM");
}


- (void)testOCSquirrelVMRegistryBoundToVM
{
    XCTAssertEqualObjects([_squirrelVM registryTable].impl.squirrelVM, _squirrelVM,
                          @"Table returned by -registryTable should have be bound to the proper Squirrel VM");
}


- (void)testOCSquirrelVMNewTableBoundToVM
{
    XCTAssertEqualObjects([_squirrelVM newTable].impl.squirrelVM, _squirrelVM,
                          @"Table returned by -newTable should have be bound to the proper Squirrel VM");
}


- (void)testOCSquirrelVMNewTableWithObjectBoundToVM
{
    sq_pushroottable(_squirrelVM.vm);
    
    HSQOBJECT root = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    XCTAssertEqualObjects([_squirrelVM newTableWithHSQObject: root].impl.squirrelVM, _squirrelVM,
                          @"Table returned by -newTableWithHSQObject: should have be bound to the proper Squirrel VM");
}


#pragma mark - default initialization tests

- (void)testNewTableHasImpl
{
    OCSquirrelTable *table = [OCSquirrelTable new];
    
    XCTAssertTrue([table.impl isKindOfClass: [OCSquirrelTableImpl class]],
                  @"Newly created OCSquirrelTable should have impl of OCSquirrelTableImpl class");
}


- (void)testNewTableHasImplWithDefaultVM
{
    OCSquirrelTable *table = [OCSquirrelTable new];
    
    XCTAssertEqualObjects(table.impl.squirrelVM, [OCSquirrelVM defaultVM],
                          @"Newly created OCSquirrelTable should be bound to default OCSquirrelVM");
}


#pragma mark - impl forwarding tests

- (void)testCountIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelTableImpl class]];
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithImpl: implMock];
    
    [[implMock expect] count];
    
    [table count];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelTable should forward -count calls to its impl");
}


- (void)testIntegerForKeyIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelTableImpl class]];
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithImpl: implMock];
    
    [(OCSquirrelTableImpl *)[implMock expect] integerForKey: @1];
    
    [table integerForKey: @1];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelTable should forward -integerForKey: calls to its impl");
}


- (void)testFloatForKeyIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelTableImpl class]];
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithImpl: implMock];
    
    [(OCSquirrelTableImpl *)[implMock expect] floatForKey: @1];
    
    [table floatForKey: @1];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelTable should forward -floatForKey: calls to its impl");
}


- (void)testBoolForKeyIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelTableImpl class]];
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithImpl: implMock];
    
    [(OCSquirrelTableImpl *)[implMock expect] boolForKey: @1];
    
    [table boolForKey: @1];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelTable should forward -boolForKey: calls to its impl");
}


- (void)testStringForKeyIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelTableImpl class]];
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithImpl: implMock];
    
    [(OCSquirrelTableImpl *)[implMock expect] stringForKey: @1];
    
    [table stringForKey: @1];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelTable should forward -stringForKey: calls to its impl");
}


- (void)testUserPointerForKeyIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelTableImpl class]];
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithImpl: implMock];
    
    [(OCSquirrelTableImpl *)[implMock expect] userPointerForKey: @1];
    
    [table userPointerForKey: @1];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelTable should forward -userPointerForKey: calls to its impl");
}


- (void)testObjectForKeyIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelTableImpl class]];
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithImpl: implMock];
    
    [(OCSquirrelTableImpl *)[implMock expect] objectForKey: @1];
    
    [table objectForKey: @1];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelTable should forward -objectForKey: calls to its impl");
}


- (void)testObjectForKeyedSubscriptIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelTableImpl class]];
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithImpl: implMock];
    
    [(OCSquirrelTableImpl *)[implMock expect] objectForKeyedSubscript: @1];
    
    __unused id result = table[@1];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelTable should forward -objectForKeyedSubscript: calls to its impl");
}


- (void)testKeyEnumeratorIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelTableImpl class]];
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithImpl: implMock];
    
    [(OCSquirrelTableImpl *)[implMock expect] keyEnumerator];
    
    [table keyEnumerator];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelTable should forward -keyEnumerator calls to its impl");
}


- (void)testSetObjectForKeyIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelTableImpl class]];
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithImpl: implMock];
    
    [(OCSquirrelTableImpl *)[implMock expect] setObject: @1 forKey: @2];
    
    [table setObject: @1 forKey: @2];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelTable should forward -setObject:forKey: calls to its impl");
}


- (void)testSetObjectForKeyedSubscriptIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelTableImpl class]];
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithImpl: implMock];
    
    [(OCSquirrelTableImpl *)[implMock expect] setObject: @1 forKeyedSubscript: @2];
    
    table[@2] = @1;
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelTable should forward -setObject:forKeyedSubscript: calls to its impl");
}


- (void)testSetIntegerForKeyIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelTableImpl class]];
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithImpl: implMock];
    
    [(OCSquirrelTableImpl *)[implMock expect] setInteger: 1 forKey: @2];
    
    [table setInteger: 1 forKey: @2];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelTable should forward -setInteger:forKey: calls to its impl");
}


- (void)testSetFloatForKeyIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelTableImpl class]];
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithImpl: implMock];
    
    [(OCSquirrelTableImpl *)[implMock expect] setFloat: 123.45 forKey: @2];
    
    [table setFloat: 123.45 forKey: @2];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelTable should forward -setFloat:forKey: calls to its impl");
}


- (void)testSetBoolForKeyIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelTableImpl class]];
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithImpl: implMock];
    
    [(OCSquirrelTableImpl *)[implMock expect] setBool: YES forKey: @2];
    
    [table setBool: YES forKey: @2];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelTable should forward -setBool:forKey: calls to its impl");
}


- (void)testSetStringForKeyIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelTableImpl class]];
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithImpl: implMock];
    
    [(OCSquirrelTableImpl *)[implMock expect] setString: @"someString" forKey: @2];
    
    [table setString: @"someString" forKey: @2];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelTable should forward -setString:forKey: calls to its impl");
}


- (void)testRemoveObjectForKeyIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelTableImpl class]];
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithImpl: implMock];
    
    [(OCSquirrelTableImpl *)[implMock expect] removeObjectForKey: @1];
    
    [table removeObjectForKey: @1];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelTable should forward -removeObjectForKey: calls to its impl");
}



- (void)testSetUserPointerForKeyIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelTableImpl class]];
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithImpl: implMock];
    
    [(OCSquirrelTableImpl *)[implMock expect] setUserPointer: (__bridge void *)self forKey: @2];
    
    [table setUserPointer: (__bridge void *)self forKey: @2];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelTable should forward -setUserPointer:forKey: calls to its impl");
}


- (void)testEnumerateObjectsAndKeysUsingBlockIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelTableImpl class]];
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithImpl: implMock];
    
    [(OCSquirrelTableImpl *)[implMock expect] enumerateObjectsAndKeysUsingBlock: OCMOCK_ANY];
    
    [table enumerateObjectsAndKeysUsingBlock:^(id key, id value, BOOL *stop) {
        
    }];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelTable should forward -enumerateObjectsAndKeysUsingBlock: calls to its impl");
}


- (void)testCallClosureWithKeyIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelTableImpl class]];
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithImpl: implMock];
    
    [(OCSquirrelTableImpl *)[implMock expect] callClosureWithKey: @1];
    
    [table callClosureWithKey: @1];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelTable should forward -callClosureWithKey: calls to its impl");
}


- (void)testCallClosureWithKeyParametersIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelTableImpl class]];
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithImpl: implMock];
    
    [(OCSquirrelTableImpl *)[implMock expect] callClosureWithKey: @1 parameters: @[]];
    
    [table callClosureWithKey: @1 parameters: @[]];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelTable should forward -callClosureWithKey:parameters: calls to its impl");
}


- (void)testSquirrelVMIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelTableImpl class]];
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithImpl: implMock];
    
    [(OCSquirrelTableImpl *)[implMock expect] squirrelVM];
    
    [table squirrelVM];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelTable should forward -squirrelVM calls to its impl");
}


- (void)testPushIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelTableImpl class]];
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithImpl: implMock];
    
    [(OCSquirrelTableImpl *)[implMock expect] push];
    
    [table push];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelTable should forward -push calls to its impl");
}


@end
