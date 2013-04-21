//
//  TestOCSquirrelRootTable.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 21.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "TestOCSquirrelRootTable.h"


#pragma mark -
#pragma mark TestOCSquirrelRootTable implementation

@implementation TestOCSquirrelRootTable

- (void) setUp
{
    [super setUp];
    _squirrelVM = [OCSquirrelVM new];
    _rootTable  = [[OCSquirrelRootTable alloc] initWithVM: _squirrelVM];
}


- (void) tearDown
{
    _rootTable  = nil;
    _squirrelVM = nil;
    [super tearDown];
}


- (void) testOCSquirrelRootTableClassExists
{
    STAssertTrue([OCSquirrelRootTable isSubclassOfClass: [OCSquirrelTable class]],
                 @"OCSquirrelRootTable class should exist and be a subclass of OCSquirrelTable");
}

@end
