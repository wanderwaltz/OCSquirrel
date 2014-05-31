//
//  TestOCSquirrelClosure+Protected.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 28.05.14.
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
#import "OCSquirrelClosure+Protected.h"
#import "OCSquirrelClosureImpl.h"


@interface TestOCSquirrelClosure_Protected : XCTestCase
{
    OCSquirrelVM *_squirrelVM;
}
@end

@implementation TestOCSquirrelClosure_Protected

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

static SQInteger VoidClosureNoParams(HSQUIRRELVM vm)
{
    return 0;
}


- (void)testOCSquirrelVMHasImplPropertyAfterInitWithImpl
{
    OCSquirrelClosureImpl *impl = [[OCSquirrelClosureImpl alloc] initWithSQFUNCTION: VoidClosureNoParams
                                                                         squirrelVM: _squirrelVM];
    OCSquirrelClosure *closure = [[OCSquirrelClosure alloc] initWithImpl: impl];
    
    XCTAssertEqualObjects(closure.impl, impl, @"-initWithImpl: should set the impl property of OCSquirrelClosure");
}


- (void)testOCSquirrelVMNewClosureWithSQFUNCTIONClass
{
    XCTAssertTrue([[_squirrelVM newClosureWithSQFUNCTION: VoidClosureNoParams] isKindOfClass: [OCSquirrelClosure class]],
                  @"Object returned by -newClosureWithSQFUNCTION: method of OCSquirrelVM "
                  @"should be of OCSquirrelClosure class");
}


- (void)testOCSquirrelVMNewClosureWithSQFUNCTIONHasImpl
{
    XCTAssertTrue([[_squirrelVM newClosureWithSQFUNCTION: VoidClosureNoParams].impl isKindOfClass:
                   [OCSquirrelClosureImpl class]],
                  @"Object returned by -newClosureWithSQFUNCTION: should have impl of OCSquirrelClosureImpl class");
}


- (void)testOCSquirrelVMNewClosureWithSQFUNCTIONBoundToVM
{
    XCTAssertEqualObjects([_squirrelVM newClosureWithSQFUNCTION: VoidClosureNoParams].impl.squirrelVM, _squirrelVM,
                          @"Array returned by -newClosureWithSQFUNCTION: should have be bound to the proper Squirrel VM");
}


#pragma mark - impl forwarding tests

- (void)testCallIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelClosureImpl class]];
    OCSquirrelClosure *closure = [[OCSquirrelClosure alloc] initWithImpl: implMock];
    
    [[implMock expect] call];
    
    [closure call];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelClosure should forward -call calls to its impl");
}


- (void)testCallWithParamsIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelClosureImpl class]];
    OCSquirrelClosure *closure = [[OCSquirrelClosure alloc] initWithImpl: implMock];
    
    [[implMock expect] call: @[@1]];
    
    [closure call: @[@1]];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelClosure should forward -call: calls to its impl");
}


- (void)testCallWithThisIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelClosureImpl class]];
    OCSquirrelClosure *closure = [[OCSquirrelClosure alloc] initWithImpl: implMock];
    
    [[implMock expect] callWithThis: (id)[NSNull null]];
    
    [closure callWithThis: (id)[NSNull null]];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelClosure should forward -callWithThis: calls to its impl");
}


- (void)testCallWithThisWithParamsIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelClosureImpl class]];
    OCSquirrelClosure *closure = [[OCSquirrelClosure alloc] initWithImpl: implMock];
    
    [[implMock expect] callWithThis: (id)[NSNull null] parameters: @[@1]];
    
    [closure callWithThis: (id)[NSNull null] parameters: @[@1]];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelClosure should forward -callWithThis:parameters: calls to its impl");
}

@end
