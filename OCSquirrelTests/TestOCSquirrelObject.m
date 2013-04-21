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


- (void) testOCSquirrelObjectClassExists
{
    STAssertNotNil([OCSquirrelObject class],
                   @"OCSquirrelObject class should exist.");
}


- (void) testHasReadonlySquirrelVMProperty
{
    STAssertTrue( [OCSquirrelObject instancesRespondToSelector: @selector(squirrelVM)] &&
                 ![OCSquirrelObject instancesRespondToSelector: @selector(setSquirrelVM:)],
                 @"OCSquirrelObject class should have a squirrelVM property.");
}


- (void) testThrowsIfSquirrelVMNotSet
{
    // This test verifies that OCSquirrelObject cannot work properly without
    // an OCSquirrelVM. Readonly property can only get its value while initializing
    // the OCSquirrelObject and if the VM is not set, all other OCSquirrelObject
    // behavior is undefined. That should obviously throw an exception.
    STAssertThrowsSpecificNamed([[OCSquirrelObject new] squirrelVM],
                                NSException, NSInternalInconsistencyException,
                                @"OCSquirrelObject should throw and NSInternalInconsistencyException "
                                @"if trying to access squirrelVM property while its value has not "
                                @"been set");
}


- (void) testInitWithVMMethodExists
{
    STAssertNotNil([[OCSquirrelObject alloc] initWithVM: _squirrelVM],
                   @"OCSquirrelObject should have an -initWithSquirrelVM initializer method.");
}


- (void) testNoThrowWhenVMSet
{
    OCSquirrelObject *object = [[OCSquirrelObject alloc] initWithVM: _squirrelVM];
    STAssertEqualObjects(object.squirrelVM, _squirrelVM,
                         @"Should not throw exception if VM has been set in initializer.");
}


- (void) testHasReadonlyObjProperty
{
    STAssertTrue( [OCSquirrelObject instancesRespondToSelector: @selector(obj)] &&
                 ![OCSquirrelObject instancesRespondToSelector: @selector(setObj:)],
                 @"OCSquirrelObject should have a readonly obj property.");
}


- (void) testNotNULLObjWhenCreated
{
    OCSquirrelObject *object = [[OCSquirrelObject alloc] initWithVM: _squirrelVM];
    STAssertTrue(object.obj != NULL,
                 @"OCSquirrelObject should have a non-NULL obj property value when created.");
}


- (void) testSQNullWhenCreated
{
    OCSquirrelObject *object = [[OCSquirrelObject alloc] initWithVM: _squirrelVM];
    STAssertTrue(sq_isnull(*object.obj),
                 @"OCSquirrelObject's obj property should have a default `null` value in Squirrel VM.");
}


- (void) testIsNullWhenCreated
{
    OCSquirrelObject *object = [[OCSquirrelObject alloc] initWithVM: _squirrelVM];
    STAssertTrue(object.isNull,
                 @"isNull property should be YES by default for OCSquirrelObject");
}


- (void) testInitWithHSQOBJECT
{
    sq_pushroottable(_squirrelVM.vm);
    
    HSQOBJECT root = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    OCSquirrelObject *object = [[OCSquirrelObject alloc] initWithHSQOBJECT: root
                                                                      inVM: _squirrelVM];
    STAssertEquals(*object.obj, root,
                   @"OCSquirrelObject should support initialization with an existing HSQOBJECT");
}


- (void) testNotNullWhenInitWithRootTable
{
    sq_pushroottable(_squirrelVM.vm);
    
    HSQOBJECT root = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    OCSquirrelObject *object = [[OCSquirrelObject alloc] initWithHSQOBJECT: root
                                                                      inVM: _squirrelVM];
    STAssertFalse(object.isNull,
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
    
    STAssertEquals(refCountInitial+1, sq_getrefcount(_squirrelVM.vm, &root),
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
    
    STAssertEquals(refCountInitial, sq_getrefcount(_squirrelVM.vm, &root),
                   @"When OCSquirrelObject deallocs it should release the HSQOBJECT");
}


- (void) testTopValueAfterPush
{
    NSInteger top = _squirrelVM.stack.top;
    
    OCSquirrelObject *object = [[OCSquirrelObject alloc] initWithVM: _squirrelVM];
    
    [object push];
    
    STAssertEquals(_squirrelVM.stack.top, top+1,
                   @"Squirrel VM stack top value should increase after pushing a OCSquirrelObject");
}

@end
