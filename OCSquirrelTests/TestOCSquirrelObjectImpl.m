//
//  TestOCSquirrelObjectImpl.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 14.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#ifndef GHUnit_Target
    #import <XCTest/XCTest.h>
#endif

#import <OCSquirrel/OCSquirrel.h>
#import "SenTestingKitCompatibility.h"
#import "OCSquirrelVM+Protected.h"
#import "OCSquirrelObjectImpl.h"


#pragma mark -
#pragma mark TestOCSquirrelObjectImpl interface

@interface TestOCSquirrelObjectImpl : XCTestCase
{
    OCSquirrelVM *_squirrelVM;
}

@end



#pragma mark -
#pragma mark TestOCSquirrelObjectImpl implementation

@implementation TestOCSquirrelObjectImpl

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

- (void) testOCSquirrelObjectImplClassExists
{
    XCTAssertNotNil([OCSquirrelObjectImpl class],
                   @"OCSquirrelObjectImpl class should exist.");
}


- (void) testHasReadonlySquirrelVMProperty
{
    XCTAssertTrue( [OCSquirrelObjectImpl instancesRespondToSelector: @selector(squirrelVM)] &&
                 ![OCSquirrelObjectImpl instancesRespondToSelector: @selector(setSquirrelVM:)],
                 @"OCSquirrelObjectImpl class should have a squirrelVM property.");
}


- (void) testInitWithVMMethodExists
{
    XCTAssertNotNil([[OCSquirrelObjectImpl alloc] initWithVM: _squirrelVM],
                   @"OCSquirrelObjectImpl should have an -initWithSquirrelVM initializer method.");
}


- (void) testNoThrowWhenVMSet
{
    OCSquirrelObjectImpl *object = [[OCSquirrelObjectImpl alloc] initWithVM: _squirrelVM];
    XCTAssertEqualObjects(object.squirrelVM, _squirrelVM,
                         @"Should not throw exception if VM has been set in initializer.");
}


- (void) testThrowsExceptionIfVMisNil
{
    XCTAssertThrowsSpecificNamed(({
        __unused OCSquirrelObjectImpl *object = [[OCSquirrelObjectImpl alloc] initWithVM: nil];
    }), NSException, NSInvalidArgumentException,
                                 @"OCSquirrelObjectImpl should throw an exception when "
                                 @"initialized with nil OCSquirrelVM");
}


- (void) testHasReadonlyObjProperty
{
    XCTAssertTrue( [OCSquirrelObjectImpl instancesRespondToSelector: @selector(obj)] &&
                 ![OCSquirrelObjectImpl instancesRespondToSelector: @selector(setObj:)],
                 @"OCSquirrelObjectImpl should have a readonly obj property.");
}


- (void) testNotNULLObjWhenCreated
{
    OCSquirrelObjectImpl *object = [[OCSquirrelObjectImpl alloc] initWithVM: _squirrelVM];
    XCTAssertTrue(object.obj != NULL,
                 @"OCSquirrelObjectImpl should have a non-NULL obj property value when created.");
}


- (void) testNotNULLObjWhenCreatedWithClassMethod
{
    OCSquirrelObjectImpl *object = [OCSquirrelObjectImpl newWithVM: _squirrelVM];
    XCTAssertTrue(object.obj != NULL,
                 @"OCSquirrelObjectImpl should have a non-NULL obj property value when created.");
}


- (void) testSQNullWhenCreated
{
    OCSquirrelObjectImpl *object = [[OCSquirrelObjectImpl alloc] initWithVM: _squirrelVM];
    XCTAssertTrue(sq_isnull(*object.obj),
                 @"OCSquirrelObjectImpl's obj property should have a default `null` value in Squirrel VM.");
}


- (void) testSQNullWhenCreatedWithClassObject
{
    OCSquirrelObjectImpl *object = [OCSquirrelObjectImpl newWithVM: _squirrelVM];
    XCTAssertTrue(sq_isnull(*object.obj),
                 @"OCSquirrelObjectImpl's obj property should have a default `null` value in Squirrel VM.");
}


- (void) testIsNullWhenCreated
{
    OCSquirrelObjectImpl *object = [[OCSquirrelObjectImpl alloc] initWithVM: _squirrelVM];
    XCTAssertTrue(object.isNull,
                 @"isNull property should be YES by default for OCSquirrelObjectImpl");
}


- (void) testInitWithHSQOBJECT
{
    sq_pushroottable(_squirrelVM.vm);
    
    HSQOBJECT root = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    OCSquirrelObjectImpl *object = [[OCSquirrelObjectImpl alloc] initWithHSQOBJECT: root
                                                                      inVM: _squirrelVM];
    XCTAssertEqualStructs(*object.obj, root,
                          @"OCSquirrelObjectImpl should support initialization with an existing HSQOBJECT");
}


- (void) testNewWithHSQOBJECT
{
    sq_pushroottable(_squirrelVM.vm);
    
    HSQOBJECT root = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    OCSquirrelObjectImpl *object = [OCSquirrelObjectImpl newWithHSQOBJECT: root
                                                             inVM: _squirrelVM];
    XCTAssertEqualStructs(*object.obj, root,
                          @"OCSquirrelObjectImpl should support initialization with an existing HSQOBJECT");
}


- (void) testNotNullWhenInitWithRootTable
{
    sq_pushroottable(_squirrelVM.vm);
    
    HSQOBJECT root = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    OCSquirrelObjectImpl *object = [[OCSquirrelObjectImpl alloc] initWithHSQOBJECT: root
                                                                      inVM: _squirrelVM];
    XCTAssertFalse(object.isNull,
                  @"-isNull shoud return NO when initializing with a non-null HSQOBJECT such as "
                  @"the Squirrel VM's root table.");
}


- (void) testRefCountIncreasesWhenInitWithHSQOBJECT
{
    sq_pushroottable(_squirrelVM.vm);
    
    HSQOBJECT root = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    NSUInteger refCountInitial = sq_getrefcount(_squirrelVM.vm, &root);
    
    OCSquirrelObjectImpl *object = [[OCSquirrelObjectImpl alloc] initWithHSQOBJECT: root
                                                                      inVM: _squirrelVM];
    
    XCTAssertEqual(refCountInitial+1, sq_getrefcount(_squirrelVM.vm, &root),
                   @"When initializing with and existing HSQOBJECT, OCSquirrelObjectImpl should "
                   @"increase the ref count by 1.");
    
    object = nil;
}


- (void) testRefCountDecreasesWhenDealloc
{
    sq_pushroottable(_squirrelVM.vm);
    
    HSQOBJECT root = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    NSUInteger refCountInitial = sq_getrefcount(_squirrelVM.vm, &root);
    
    OCSquirrelObjectImpl *object = [[OCSquirrelObjectImpl alloc] initWithHSQOBJECT: root
                                                                      inVM: _squirrelVM];
    object = nil;
    
    XCTAssertEqual(refCountInitial, sq_getrefcount(_squirrelVM.vm, &root),
                   @"When OCSquirrelObjectImpl deallocs it should release the HSQOBJECT");
}


- (void) testTopValueAfterPush
{
    NSInteger top = _squirrelVM.stack.top;
    
    OCSquirrelObjectImpl *object = [[OCSquirrelObjectImpl alloc] initWithVM: _squirrelVM];
    
    [object push];
    
    XCTAssertEqual(_squirrelVM.stack.top, top+1,
                   @"Squirrel VM stack top value should increase after pushing a OCSquirrelObjectImpl");
}

@end
