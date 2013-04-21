//
//  TestRawSquirrelAPI.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 13.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import "TestRawSquirrelAPI.h"


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
    STAssertTrue(_vm != NULL, @"Squirrel VM should exist.");
}


- (void) testPushRootTableRefCount
{
    sq_pushroottable(_vm);
    
    HSQOBJECT root;
    
    sq_getstackobj(_vm, -1, &root);
    
    STAssertEquals(sq_getrefcount(_vm, &root), 0u,
                   @"Reference count of the root table should be equal to 0 before adding ref");
    
    sq_addref(_vm, &root);
    
    STAssertEquals(sq_getrefcount(_vm, &root), 1u,
                   @"Reference count of the root table should be equal to 1 after adding ref");
    
    sq_release(_vm, &root);
    
    STAssertEquals(sq_getrefcount(_vm, &root), 0u,
                   @"Reference count of the root table should be equal to 0 after releasing ref");
}

@end
