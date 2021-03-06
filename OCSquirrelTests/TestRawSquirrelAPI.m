//
//  TestRawSquirrelAPI.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 13.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#ifndef GHUnit_Target
#import <XCTest/XCTest.h>
#endif

#import <OCSquirrel/OCSquirrel.h>

#pragma mark -
#pragma mark TestRawSquirrelAPI

/*! General Squirrel API tests will be included here. Obviously testing the Squirrel itself completely is somewhat 
 *  out of scope of this project, but to some extent it may be useful to test parts of the Squirrel functionality 
 *  which are actually used by the OCSquirrel.
 */
@interface TestRawSquirrelAPI : XCTestCase
{
    HSQUIRRELVM _vm;
}

@end


#pragma mark -
#pragma mark TestRawSquirrelAPI implementation

@implementation TestRawSquirrelAPI

- (void) setUp
{
    [super setUp];
    _vm = sq_open(1024);
}

- (void) tearDown
{
    sq_close(_vm);
    [super tearDown];
}


- (void) testSquirrelVMExists
{
    XCTAssertTrue(_vm != NULL, @"Squirrel VM should exist.");
}


- (void) testPushRootTableRefCount
{
    sq_pushroottable(_vm);
    
    HSQOBJECT root;
    
    sq_getstackobj(_vm, -1, &root);
    
    XCTAssertEqual((SQUnsignedInteger)sq_getrefcount(_vm, &root), (SQUnsignedInteger)0,
                   @"Reference count of the root table should be equal to 0 before adding ref");
    
    sq_addref(_vm, &root);
    
    XCTAssertEqual((SQUnsignedInteger)sq_getrefcount(_vm, &root), (SQUnsignedInteger)1,
                   @"Reference count of the root table should be equal to 1 after adding ref");
    
    sq_release(_vm, &root);
    
    XCTAssertEqual((SQUnsignedInteger)sq_getrefcount(_vm, &root), (SQUnsignedInteger)0,
                   @"Reference count of the root table should be equal to 0 after releasing ref");
}


- (void) testObjectCopyRefCount1
{
    sq_pushroottable(_vm);
    
    HSQOBJECT root1;
    HSQOBJECT root2;
    
    sq_getstackobj(_vm, -1, &root1);
    sq_getstackobj(_vm, -1, &root2);
    
    sq_addref(_vm, &root1);
    
    XCTAssertEqual((SQUnsignedInteger)sq_getrefcount(_vm, &root2), (SQUnsignedInteger)1,
                   @"Reference count should be retrieved regardless of which instance of HSQOBJECT "
                   @"we are working with.");
}


- (void) testObjectCopyRefCount2
{
    sq_pushroottable(_vm);
    
    HSQOBJECT root1;
    HSQOBJECT root2;
    
    sq_getstackobj(_vm, -1, &root1);
    root2 = root1;
    
    sq_addref(_vm, &root1);
    
    XCTAssertEqual((SQUnsignedInteger)sq_getrefcount(_vm, &root2), (SQUnsignedInteger)1,
                   @"Reference count should be retrieved regardless of which instance of HSQOBJECT "
                   @"we are working with.");
}


- (void) testNonStringKey
{
    static const SQInteger key   = 123;
    static const SQInteger value = 456;
    
    sq_pushroottable(_vm);
    
    SQInteger top = sq_gettop(_vm);
    
    sq_pushinteger(_vm, key);
    sq_pushinteger(_vm, value);
    
    sq_newslot(_vm, -3, SQFalse);
    
    sq_settop(_vm, top);
    
    sq_pushroottable(_vm);
    sq_pushinteger(_vm, key);
    
    sq_get(_vm, -2);
    
    SQInteger readValue = 0;
    
    sq_getinteger(_vm, -1, &readValue);
    
    XCTAssertEqual(readValue, value,
                   @"Should be able to create slots with non-string based keys");
}


static BOOL g_ReleaseHookCalled = NO;

SQInteger ReleaseHook(SQUserPointer pointer, SQInteger size)
{
    g_ReleaseHookCalled = YES;
    
    return 0;
}

- (void) testReleaseHook
{
    g_ReleaseHookCalled = NO;
    sq_newuserdata(_vm, 123);
    sq_setreleasehook(_vm, -1, ReleaseHook);
    sq_pop(_vm, 1);
    
    XCTAssertTrue(g_ReleaseHookCalled,
                 @"Release hook function should be called after popping the newly created "
                 @"user data object from the stack.");
}

@end
