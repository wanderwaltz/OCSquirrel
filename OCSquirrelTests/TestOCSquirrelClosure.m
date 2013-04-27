//
//  TestOCSquirrelClosure.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 27.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "TestOCSquirrelClosure.h"


#pragma mark -
#pragma mark Helpers

static NSString * const kClosureCalledNotification = @"Closure Called";

static SQInteger VoidClosureNoParams(HSQUIRRELVM vm)
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kClosureCalledNotification
                                                        object: nil];
    
    return 0;
}


#pragma mark -
#pragma mark TestOCSquirrelClosure implementation

@implementation TestOCSquirrelClosure

#pragma mark -
#pragma mark initialization

- (void) setUp
{
    [super setUp];
    _squirrelVM    = [[OCSquirrelVM alloc] init];
    _root          = [OCSquirrelTable rootTableForVM: _squirrelVM];
    _closureCalled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleClosureCalledNotification:)
                                                 name: kClosureCalledNotification
                                               object: nil];
}


- (void) tearDown
{
    _root       = nil;
    _squirrelVM = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    [super tearDown];
}


#pragma mark -
#pragma mark tests

- (void) testNewClosure
{
    OCSquirrelClosure *closure = [[OCSquirrelClosure alloc] initWithSQFUNCTION: VoidClosureNoParams
                                                                    squirrelVM: _squirrelVM];
    
    STAssertNotNil(closure,
                   @"OCSquirrelClosure class should exist.");
}


#pragma mark -
#pragma mark notifications

- (void) handleClosureCalledNotification: (NSNotification *) notification
{
    _closureCalled = YES;
}

@end
