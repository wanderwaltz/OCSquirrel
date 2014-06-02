//
//  TestOCSquirrelClass+Protected.m
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
#import "OCSquirrelClass+Protected.h"
#import "OCSquirrelClassImpl.h"


@interface TestOCSquirrelClass_Protected : XCTestCase
{
    OCSquirrelVM *_squirrelVM;
}
@end


@implementation TestOCSquirrelClass_Protected

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
    OCSquirrelClassImpl *impl = [[OCSquirrelClassImpl alloc] initWithSquirrelVM: _squirrelVM];
    OCSquirrelClass *class = [[OCSquirrelClass alloc] initWithImpl: impl];
    
    XCTAssertEqualObjects(class.impl, impl, @"-initWithImpl: should set the impl property of OCSquirrelClass");
}


- (void)testOCSquirrelVMBindClassClass
{
    XCTAssertTrue([[_squirrelVM bindClass: [NSDate class]] isKindOfClass: [OCSquirrelClass class]],
                  @"Object returned by -bindClass: method of OCSquirrelVM "
                  @"should be of OCSquirrelClass class");
}


- (void)testOCSquirrelVMBindClassHasImpl
{
    XCTAssertTrue([[_squirrelVM bindClass: [NSDate class]].impl isKindOfClass: [OCSquirrelClassImpl class]],
                  @"Object returned by -bindClass: should have impl of OCSquirrelClass class");
}


- (void)testOCSquirrelVMBindClassBoundToVM
{
    XCTAssertEqualObjects([_squirrelVM bindClass: [NSDate class]].impl.squirrelVM, _squirrelVM,
                          @"Array returned by -bindClass: should have be bound to the proper Squirrel VM");
}


#pragma mark - impl forwarding tests

- (void)testSquirrelVMIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelClassImpl class]];
    OCSquirrelClass *class = [[OCSquirrelClass alloc] initWithImpl: implMock];
    
    [[implMock expect] squirrelVM];
    
    [class squirrelVM];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelClass should forward -squirrelVM calls to its impl");
}


- (void)testObjIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelClassImpl class]];
    OCSquirrelClass *class = [[OCSquirrelClass alloc] initWithImpl: implMock];
    
    [[implMock expect] obj];
    
    [class obj];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelClass should forward -obj calls to its impl");
}


- (void)testTypeIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelClassImpl class]];
    OCSquirrelClass *class = [[OCSquirrelClass alloc] initWithImpl: implMock];
    
    [(OCSquirrelClassImpl *)[implMock expect] type];
    
    [class type];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelClass should forward -type calls to its impl");
}


- (void)testPushIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelClassImpl class]];
    OCSquirrelClass *class = [[OCSquirrelClass alloc] initWithImpl: implMock];
    
    [[implMock expect] push];
    
    [class push];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelClass should forward -push calls to its impl");
}


- (void)testNativeClassIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelClassImpl class]];
    OCSquirrelClass *class = [[OCSquirrelClass alloc] initWithImpl: implMock];
    
    [[implMock expect] nativeClass];
    
    [class nativeClass];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelClass should forward -nativeClass calls to its impl");
}


- (void)testSetClassAttributesIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelClassImpl class]];
    OCSquirrelClass *class = [[OCSquirrelClass alloc] initWithImpl: implMock];
    
    [[implMock expect] setClassAttributes: [NSNull null]];
    
    [class setClassAttributes: [NSNull null]];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelClass should forward -setClassAttributes: calls to its impl");
}


- (void)testClassAttributesIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelClassImpl class]];
    OCSquirrelClass *class = [[OCSquirrelClass alloc] initWithImpl: implMock];
    
    [[implMock expect] classAttributes];
    
    [class classAttributes];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelClass should forward -classAttributes calls to its impl");
}


- (void)testPushNewInstanceIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelClassImpl class]];
    OCSquirrelClass *class = [[OCSquirrelClass alloc] initWithImpl: implMock];
    
    [[implMock expect] pushNewInstance];
    
    [class pushNewInstance];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelClass should forward -pushNewInstance calls to its impl");
}


- (void)testBindInstanceMethodWithSelectorErrorIsForwardedToImpl
{
    id implMock = [OCMockObject mockForClass: [OCSquirrelClassImpl class]];
    OCSquirrelClass *class = [[OCSquirrelClass alloc] initWithImpl: implMock];
    
    [[implMock expect] bindInstanceMethodWithSelector: @selector(description) error: nil];
    
    [class bindInstanceMethodWithSelector: @selector(description) error: nil];
    
    XCTAssertNoThrow([implMock verify],
                     @"OCSquirrelClass should forward -bindInstanceMethodWithSelector:error: calls to its impl");
}


@end
