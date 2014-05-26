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


#pragma mark - OCSquirrelTable integration

- (void)testHasImplPropertyAfterInitWithImpl
{
    OCSquirrelTableImpl *impl = [[OCSquirrelTableImpl alloc] initWithVM: _squirrelVM];
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithImpl: impl];
    
    XCTAssertEqualObjects(table.impl, impl, @"-initWithImpl: should set the impl property of OCSquirrelTable");
}


- (void)testRootTableClass
{
    XCTAssertTrue([[_squirrelVM rootTable] isKindOfClass: [OCSquirrelTable class]],
                  @"Object returned by -rootTable method of OCSquirrelVM should be of OCSquirrelTable class");
}


- (void)testRegistryTableClass
{
    XCTAssertTrue([[_squirrelVM registryTable] isKindOfClass: [OCSquirrelTable class]],
                  @"Object returned by -registryTable method of OCSquirrelVM should be of OCSquirrelTable class");
}


- (void)testNewTableClass
{
    XCTAssertTrue([[_squirrelVM newTable] isKindOfClass: [OCSquirrelTable class]],
                  @"Object returned by -newTable method of OCSquirrelVM should be of OCSquirrelTable class");
}


- (void)testNewTableWithObjectClass
{
    sq_pushroottable(_squirrelVM.vm);
    
    HSQOBJECT root = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    XCTAssertTrue([[_squirrelVM newTableWithHSQObject: root] isKindOfClass: [OCSquirrelTable class]],
                  @"Object returned by -newTableWithHSQObject: should be of OCSquirrelTable class");
}


- (void)testRootTableHasImpl
{
    XCTAssertTrue([[_squirrelVM rootTable].impl isKindOfClass: [OCSquirrelTableImpl class]],
                  @"Object returned by -rootTable should have impl of OCSquirrelTableImpl class");
}


- (void)testRegistryTableHasImpl
{
    XCTAssertTrue([[_squirrelVM registryTable].impl isKindOfClass: [OCSquirrelTableImpl class]],
                  @"Object returned by -registryTable should have impl of OCSquirrelTableImpl class");
}


- (void)testNewTableHasImpl
{
    XCTAssertTrue([[_squirrelVM newTable].impl isKindOfClass: [OCSquirrelTableImpl class]],
                  @"Object returned by -newTable should have impl of OCSquirrelTableImpl class");
}


- (void)testNewTableWithObjectHasImpl
{
    sq_pushroottable(_squirrelVM.vm);
    
    HSQOBJECT root = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    XCTAssertTrue([[_squirrelVM newTableWithHSQObject: root].impl isKindOfClass: [OCSquirrelTableImpl class]],
                  @"Object returned by -newTableWithHSQObject: should have impl of OCSquirrelTableImpl class");
}

@end
