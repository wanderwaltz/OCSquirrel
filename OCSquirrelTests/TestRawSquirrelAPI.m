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
    _squirrelVM = sq_open(1024);
}

- (void) tearDown
{
    sq_close(_squirrelVM);
    [super tearDown];
}


- (void) testSquirrelVMExists
{
    STAssertTrue(_squirrelVM != NULL, @"Squirrel VM should exist.");
}

@end
