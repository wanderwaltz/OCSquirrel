//
//  TestOCSquirrelObject.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 14.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "TestOCSquirrelObject.h"
#import "SenTestingKitCompatibility.h"


#pragma mark -
#pragma mark TestOCSquirrelObject implementation

@implementation TestOCSquirrelObject

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

- (void) testOCSquirrelObjectClassExists
{
    XCTAssertNotNil([OCSquirrelObject class],
                   @"OCSquirrelObject class should exist.");
}


- (void) testHasReadonlySquirrelVMProperty
{
    XCTAssertTrue( [OCSquirrelObject instancesRespondToSelector: @selector(squirrelVM)] &&
                 ![OCSquirrelObject instancesRespondToSelector: @selector(setSquirrelVM:)],
                 @"OCSquirrelObject class should have a squirrelVM property.");
}


- (void) testInitWithVMMethodExists
{
    XCTAssertNotNil([[OCSquirrelObject alloc] initWithVM: _squirrelVM],
                   @"OCSquirrelObject should have an -initWithSquirrelVM initializer method.");
}


- (void) testNoThrowWhenVMSet
{
    OCSquirrelObject *object = [[OCSquirrelObject alloc] initWithVM: _squirrelVM];
    XCTAssertEqualObjects(object.squirrelVM, _squirrelVM,
                         @"Should not throw exception if VM has been set in initializer.");
}


- (void) testHasReadonlyObjProperty
{
    XCTAssertTrue( [OCSquirrelObject instancesRespondToSelector: @selector(obj)] &&
                 ![OCSquirrelObject instancesRespondToSelector: @selector(setObj:)],
                 @"OCSquirrelObject should have a readonly obj property.");
}


- (void) testNotNULLObjWhenCreated
{
    OCSquirrelObject *object = [[OCSquirrelObject alloc] initWithVM: _squirrelVM];
    XCTAssertTrue(object.obj != NULL,
                 @"OCSquirrelObject should have a non-NULL obj property value when created.");
}


- (void) testNotNULLObjWhenCreatedWithClassMethod
{
    OCSquirrelObject *object = [OCSquirrelObject newWithVM: _squirrelVM];
    XCTAssertTrue(object.obj != NULL,
                 @"OCSquirrelObject should have a non-NULL obj property value when created.");
}


- (void) testSQNullWhenCreated
{
    OCSquirrelObject *object = [[OCSquirrelObject alloc] initWithVM: _squirrelVM];
    XCTAssertTrue(sq_isnull(*object.obj),
                 @"OCSquirrelObject's obj property should have a default `null` value in Squirrel VM.");
}


- (void) testSQNullWhenCreatedWithClassObject
{
    OCSquirrelObject *object = [OCSquirrelObject newWithVM: _squirrelVM];
    XCTAssertTrue(sq_isnull(*object.obj),
                 @"OCSquirrelObject's obj property should have a default `null` value in Squirrel VM.");
}


- (void) testIsNullWhenCreated
{
    OCSquirrelObject *object = [[OCSquirrelObject alloc] initWithVM: _squirrelVM];
    XCTAssertTrue(object.isNull,
                 @"isNull property should be YES by default for OCSquirrelObject");
}


- (void) testInitWithHSQOBJECT
{
    sq_pushroottable(_squirrelVM.vm);
    
    HSQOBJECT root = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    OCSquirrelObject *object = [[OCSquirrelObject alloc] initWithHSQOBJECT: root
                                                                      inVM: _squirrelVM];
    XCTAssertEqualStructs(*object.obj, root,
                          @"OCSquirrelObject should support initialization with an existing HSQOBJECT");
}


- (void) testNewWithHSQOBJECT
{
    sq_pushroottable(_squirrelVM.vm);
    
    HSQOBJECT root = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    OCSquirrelObject *object = [OCSquirrelObject newWithHSQOBJECT: root
                                                             inVM: _squirrelVM];
    XCTAssertEqualStructs(*object.obj, root,
                          @"OCSquirrelObject should support initialization with an existing HSQOBJECT");
}


- (void) testNotNullWhenInitWithRootTable
{
    sq_pushroottable(_squirrelVM.vm);
    
    HSQOBJECT root = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    OCSquirrelObject *object = [[OCSquirrelObject alloc] initWithHSQOBJECT: root
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
    
    OCSquirrelObject *object = [[OCSquirrelObject alloc] initWithHSQOBJECT: root
                                                                      inVM: _squirrelVM];
    
    XCTAssertEqual(refCountInitial+1, sq_getrefcount(_squirrelVM.vm, &root),
                   @"When initializing with and existing HSQOBJECT, OCSquirrelObject should "
                   @"increase the ref count by 1.");
    
    object = nil;
}


- (void) testRefCountDecreasesWhenDealloc
{
    sq_pushroottable(_squirrelVM.vm);
    
    HSQOBJECT root = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    NSUInteger refCountInitial = sq_getrefcount(_squirrelVM.vm, &root);
    
    OCSquirrelObject *object = [[OCSquirrelObject alloc] initWithHSQOBJECT: root
                                                                      inVM: _squirrelVM];
    object = nil;
    
    XCTAssertEqual(refCountInitial, sq_getrefcount(_squirrelVM.vm, &root),
                   @"When OCSquirrelObject deallocs it should release the HSQOBJECT");
}


- (void) testTopValueAfterPush
{
    NSInteger top = _squirrelVM.stack.top;
    
    OCSquirrelObject *object = [[OCSquirrelObject alloc] initWithVM: _squirrelVM];
    
    [object push];
    
    XCTAssertEqual(_squirrelVM.stack.top, top+1,
                   @"Squirrel VM stack top value should increase after pushing a OCSquirrelObject");
}

@end
