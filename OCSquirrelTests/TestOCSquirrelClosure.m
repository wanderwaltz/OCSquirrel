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
static const NSInteger kNativeIntegerReturnValue   = 12345;

static SQInteger VoidClosureNoParams(HSQUIRRELVM vm)
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kClosureCalledNotification
                                                        object: nil];
    
    return 0;
}


static SQInteger IntClosureNoParams(HSQUIRRELVM vm)
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kClosureCalledNotification
                                                        object: nil];
    
    OCSquirrelVM *squirrelVM = OCSquirrelVMforVM(vm);
    
    [squirrelVM.stack pushInteger: kNativeIntegerReturnValue];
    
    return 1;
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


- (void) testNewClosureType
{
    OCSquirrelClosure *closure = [[OCSquirrelClosure alloc] initWithSQFUNCTION: VoidClosureNoParams
                                                                    squirrelVM: _squirrelVM];
    
    STAssertEquals(closure.type, OT_NATIVECLOSURE,
                   @"OCSquirrelClosure created with a native function should have OT_NATIVECLOSURE type.");
}


- (void) testNativeVoidCallNoParams
{
    OCSquirrelClosure *closure = [[OCSquirrelClosure alloc] initWithSQFUNCTION: VoidClosureNoParams
                                                                    squirrelVM: _squirrelVM];
    [closure call];
    STAssertTrue(_closureCalled,
                 @"call method should call the native C function bound to Squirrel closure.");
}


- (void) testNativeVoidCallNoParamsReturnValue
{
    // Push some value to the stack to be sure that it is not empty.
    [_squirrelVM.stack pushFloat: 13.37];
    
    OCSquirrelClosure *closure = [[OCSquirrelClosure alloc] initWithSQFUNCTION: VoidClosureNoParams
                                                                    squirrelVM: _squirrelVM];
    id result = [closure call];
    STAssertNil(result,
                @"For a closure which does not push a result to the Squirrel stack, "
                @"the return value of call should be nil.");
}


- (void) testNativeIntCallNoParamsReturnValue
{
    // Push some value to the stack to be sure that it is not empty.
    [_squirrelVM.stack pushFloat: 13.37];
    
    OCSquirrelClosure *closure = [[OCSquirrelClosure alloc] initWithSQFUNCTION: IntClosureNoParams
                                                                    squirrelVM: _squirrelVM];
    id result = [closure call];
    STAssertEqualObjects(result, @12345,
                         @"For a closure which does push a result to the Squirrel stack, "
                         @"the return value of call should be the value pushed by the closure.");
}


- (void) testNativeIntCallNoParamsStackState
{
    // Push some value to the stack to be sure that it is not empty.
    [_squirrelVM.stack pushFloat: 13.37];
    
    OCSquirrelClosure *closure = [[OCSquirrelClosure alloc] initWithSQFUNCTION: IntClosureNoParams
                                                                    squirrelVM: _squirrelVM];
    [closure call];
    STAssertEqualsWithAccuracy(13.37f, [[_squirrelVM.stack valueAtPosition: -1] floatValue], 1e-3,
                               @"The stack state should not change after calling the closure.");
}





#pragma mark -
#pragma mark notifications

- (void) handleClosureCalledNotification: (NSNotification *) notification
{
    _closureCalled = YES;
}

@end
