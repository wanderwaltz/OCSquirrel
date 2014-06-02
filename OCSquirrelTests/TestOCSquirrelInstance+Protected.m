//
//  TestOCSquirrelClassImpl+Protected.m
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
#import "OCMock.h"
#import "OCSquirrelVM+Protected.h"
#import "OCSquirrelInstance+Protected.h"
#import "OCSquirrelInstanceImpl.h"
#import "OCSquirrelClass.h"


@interface TestOCSquirrelInstance_Protected : XCTestCase
{
    OCSquirrelVM *_squirrelVM;
}
@end

@implementation TestOCSquirrelInstance_Protected

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
    OCSquirrelInstanceImpl *impl = [[OCSquirrelInstanceImpl alloc] initWithSquirrelVM: _squirrelVM];
    OCSquirrelInstance *instance = [[OCSquirrelInstance alloc] initWithImpl: impl];
    
    XCTAssertEqualObjects(instance.impl, impl, @"-initWithImpl: should set the impl property of OCSquirrelInstance");
}


- (void)testOCSquirrelVMPushNewInstanceClass
{
    OCSquirrelClass *class = [_squirrelVM bindClass: [NSDate class]];
    
    [class pushNewInstance];
    
    OCSquirrelInstance *instance = [_squirrelVM.stack valueAtPosition: -1];
    
    XCTAssertTrue([instance isKindOfClass: [OCSquirrelInstance class]],
                  @"Object pushed to OCSquirrelVM stack by -pushNewInstance method of OCSquirrelClass "
                  @"should be of OCSquirrelInstance class");
}


- (void)testOCSquirrelVMPushNewInstanceHasImpl
{
    OCSquirrelClass *class = [_squirrelVM bindClass: [NSDate class]];
    
    [class pushNewInstance];
    
    OCSquirrelInstance *instance = [_squirrelVM.stack valueAtPosition: -1];
    
    XCTAssertTrue([instance.impl isKindOfClass: [OCSquirrelInstanceImpl class]],
                  @"Object pushed to OCSquirrelVM stack by -pushNewInstance method of OCSquirrelClass "
                  @"should have impl of OCSquirrelInstanceImpl class");
}


- (void)testOCSquirrelVMPushNewInstanceBoundToVM
{
    OCSquirrelClass *class = [_squirrelVM bindClass: [NSDate class]];
    
    [class pushNewInstance];
    
    OCSquirrelInstance *instance = [_squirrelVM.stack valueAtPosition: -1];
    
    XCTAssertEqualObjects(instance.impl.squirrelVM, _squirrelVM,
                          @"Object pushed to OCSquirrelVM stack by -pushNewInstance method of OCSquirrelClass "
                          @"should be bound to the proper Squirrel VM");
}


#pragma mark - impl forwarding tests

- (void)testSquirrelVMIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelInstanceImpl class]];
    OCSquirrelInstance *instance = [[OCSquirrelInstance alloc] initWithImpl: implMock];
    
    [[implMock expect] squirrelVM];
    
    [instance squirrelVM];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelInstance should forward -squirrelVM calls to its impl");
}


- (void)testObjIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelInstanceImpl class]];
    OCSquirrelInstance *instance = [[OCSquirrelInstance alloc] initWithImpl: implMock];
    
    [[implMock expect] obj];
    
    [instance obj];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelInstance should forward -obj calls to its impl");
}


- (void)testTypeIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelInstanceImpl class]];
    OCSquirrelInstance *instance = [[OCSquirrelInstance alloc] initWithImpl: implMock];
    
    [(OCSquirrelInstanceImpl *)[implMock expect] type];
    
    [instance type];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelInstance should forward -type calls to its impl");
}


- (void)testPushIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelInstanceImpl class]];
    OCSquirrelInstance *instance = [[OCSquirrelInstance alloc] initWithImpl: implMock];
    
    [[implMock expect] push];
    
    [instance push];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelInstance should forward -push calls to its impl");
}


- (void)testInstanceUPIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelInstanceImpl class]];
    OCSquirrelInstance *instance = [[OCSquirrelInstance alloc] initWithImpl: implMock];
    
    [[implMock expect] instanceUP];
    
    [instance instanceUP];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelInstance should forward -instanceUP calls to its impl");
}


- (void)testObjectForKeyIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelInstanceImpl class]];
    OCSquirrelInstance *instance = [[OCSquirrelInstance alloc] initWithImpl: implMock];
    
    [[implMock expect] objectForKey: @"key"];
    
    [instance objectForKey: @"key"];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelInstance should forward -objectForKey: calls to its impl");
}


- (void)testObjectForKeyedSubscriptIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelInstanceImpl class]];
    OCSquirrelInstance *instance = [[OCSquirrelInstance alloc] initWithImpl: implMock];
    
    [[implMock expect] objectForKeyedSubscript: @"key"];
    
    __unused id result = instance[@"key"];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelInstance should forward -objectForKeyedSubscript: calls to its impl");
}


- (void)testSetObjectForKeyIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelInstanceImpl class]];
    OCSquirrelInstance *instance = [[OCSquirrelInstance alloc] initWithImpl: implMock];
    
    [[implMock expect] setObject: @1 forKey: @2];
    
    [instance setObject: @1 forKey: @2];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelInstance should forward -setObject:forKey: calls to its impl");
}


- (void)testSetObjectForKeyedSubscriptIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelInstanceImpl class]];
    OCSquirrelInstance *instance = [[OCSquirrelInstance alloc] initWithImpl: implMock];
    
    [[implMock expect] setObject: @1 forKeyedSubscript: @2];
    
    instance[@2] = @1;
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelInstance should forward -setObject:forKeyedSubscript: calls to its impl");
}


- (void)testCallClosureWithKeyIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelInstanceImpl class]];
    OCSquirrelInstance *instance = [[OCSquirrelInstance alloc] initWithImpl: implMock];
    
    [[implMock expect] callClosureWithKey: @1];
    
    [instance callClosureWithKey: @1];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelInstance should forward -callClosureWithKey: calls to its impl");
}


- (void)testCallClosureWithKeyParametersIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelInstanceImpl class]];
    OCSquirrelInstance *instance = [[OCSquirrelInstance alloc] initWithImpl: implMock];
    
    [[implMock expect] callClosureWithKey: @1 parameters: @[@2]];
    
    [instance callClosureWithKey: @1 parameters: @[@2]];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelInstance should forward -callClosureWithKey:parameters: calls to its impl");
}

@end
