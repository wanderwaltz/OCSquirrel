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
static NSString * const kEnvironmentKey = @"key";

static SQInteger VoidClosureNoParams(HSQUIRRELVM vm)
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kClosureCalledNotification
                                                        object: nil];
    
    return 0;
}


static SQInteger IntClosureNoParams(HSQUIRRELVM vm)
{
    OCSquirrelVM *squirrelVM = OCSquirrelVMforVM(vm);
    
    [squirrelVM.stack pushInteger: kNativeIntegerReturnValue];
    
    return 1;
}


static SQInteger IntClosureReturn1IntParam(HSQUIRRELVM vm)
{
    OCSquirrelVM *squirrelVM = OCSquirrelVMforVM(vm);
    
    [squirrelVM.stack pushInteger: [squirrelVM.stack integerAtPosition: -1]];
    
    return 1;
}


static SQInteger IntClosureNoParamsCheckEnvironment(HSQUIRRELVM vm)
{
    OCSquirrelVM *squirrelVM = OCSquirrelVMforVM(vm);
    
    OCSquirrelTable *table = [squirrelVM.stack valueAtPosition: 1];
    
    [squirrelVM.stack pushInteger: [table integerForKey: kEnvironmentKey]];
    
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
    STAssertEqualObjects(result, @(kNativeIntegerReturnValue),
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


- (void) testNativeIntCallIntParamReturnValue
{
    OCSquirrelClosure *closure = [[OCSquirrelClosure alloc] initWithSQFUNCTION: IntClosureReturn1IntParam
                                                                    squirrelVM: _squirrelVM];
    id result = [closure call: @[@12345]];
    STAssertEqualObjects(result, @12345,
                         @"Native closure should receive the parameter and return the appropriate "
                         @"result value.");
}


- (void) testNativeEnvironmentRootTableNoParams
{
    [_root setInteger: 12345 forKey: kEnvironmentKey];
    
    OCSquirrelClosure *closure = [[OCSquirrelClosure alloc] initWithSQFUNCTION:
                                  IntClosureNoParamsCheckEnvironment
                                                                    squirrelVM: _squirrelVM];
    id result = [closure callWithThis: _root];
    STAssertEqualObjects(result, @12345,
                         @"IntClosureNoParamsCheckEnvironment should read the value from "
                         @"the environment table passed to it by callWithEnvironment:");
}


- (void) testNativeEnvironmentOtherTableNoParams
{
    [_root setInteger: 12345 forKey: kEnvironmentKey];
    
    OCSquirrelTable *otherEnvironment = [[OCSquirrelTable alloc] initWithVM: _squirrelVM];
    
    [otherEnvironment setInteger: 6789 forKey: kEnvironmentKey];
    [_root setObject: otherEnvironment forKey: @"other environment"];
    
    OCSquirrelClosure *closure = [[OCSquirrelClosure alloc] initWithSQFUNCTION:
                                  IntClosureNoParamsCheckEnvironment
                                                                    squirrelVM: _squirrelVM];
    id result = [closure callWithThis: otherEnvironment];
    STAssertEqualObjects(result, @6789,
                         @"IntClosureNoParamsCheckEnvironment should read the value from "
                         @"the environment table passed to it by callWithEnvironment:");
}


- (void) testSquirrelVoidCallNoParams
{
    [_squirrelVM executeSync: @"function VoidNoParams() { called <- 12345; }" error: nil];
    
    OCSquirrelClosure *closure = [_root objectForKey: @"VoidNoParams"];
    [closure call];
    
    STAssertEquals([_root integerForKey: @"called"], 12345,
                 @"call method should call the Squirrel closure");
}


- (void) testSquirrelVoidCallNoParamsReturnValue
{
    // Push some value to the stack to be sure that it is not empty.
    [_squirrelVM.stack pushFloat: 13.37];
    
    [_squirrelVM executeSync: @"function VoidNoParams() {}" error: nil];
    
    OCSquirrelClosure *closure = [_root objectForKey: @"VoidNoParams"];
    id result = [closure call];
    STAssertNil(result,
                @"For a closure which does not push a result to the Squirrel stack, "
                @"the return value of call should be nil.");
}


- (void) testSquirrelIntCallNoParamsReturnValue
{
    // Push some value to the stack to be sure that it is not empty.
    [_squirrelVM.stack pushFloat: 13.37];
    
    [_squirrelVM executeSync: @"function IntNoParams() { return 12345; }" error: nil];
    
    OCSquirrelClosure *closure = [_root objectForKey: @"IntNoParams"];
    
    id result = [closure call];
    STAssertEqualObjects(result, @(12345),
                         @"For a closure which does push a result to the Squirrel stack, "
                         @"the return value of call should be the value pushed by the closure.");
}


- (void) testSquirrelIntCallNoParamsStackState
{
    // Push some value to the stack to be sure that it is not empty.
    [_squirrelVM.stack pushFloat: 13.37];
    
    [_squirrelVM executeSync: @"function IntNoParams() { return 12345; }" error: nil];
    
    OCSquirrelClosure *closure = [_root objectForKey: @"IntNoParams"];
    
    [closure call];
    STAssertEqualsWithAccuracy(13.37f, [[_squirrelVM.stack valueAtPosition: -1] floatValue], 1e-3,
                               @"The stack state should not change after calling the closure.");
}


- (void) testSquirrelIntCallIntParamReturnValue
{
    [_squirrelVM executeSync: @"function IntReturn1IntParam(x) { return x; }" error: nil];
    
    OCSquirrelClosure *closure = [_root objectForKey: @"IntReturn1IntParam"];
    
    id result = [closure call: @[@12345]];
    STAssertEqualObjects(result, @12345,
                         @"Native closure should receive the parameter and return the appropriate "
                         @"result value.");
}


- (void) testSquirrelEnvironmentRootTableNoParams
{
    [_root setInteger: 12345 forKey: @"x"];
    
    [_squirrelVM executeSync: @"function ReturnEnvironmentX() { return x; }" error: nil];
    
    OCSquirrelClosure *closure = [_root objectForKey: @"ReturnEnvironmentX"];
    
    id result = [closure callWithThis: _root];
    STAssertEqualObjects(result, @12345,
                         @"Squirrel closure should read the value from "
                         @"the environment table passed to it by callWithEnvironment:");
}


- (void) testSquirrelEnvironmentOtherTableNoParams
{
    [_root setInteger: 12345 forKey: @"x"];
    
    OCSquirrelTable *otherEnvironment = [[OCSquirrelTable alloc] initWithVM: _squirrelVM];
    
    [otherEnvironment setInteger: 6789 forKey: @"x"];
    [_root setObject: otherEnvironment forKey: @"other environment"];
    
    [_squirrelVM executeSync: @"function ReturnEnvironmentX() { return x; }" error: nil];
    
    OCSquirrelClosure *closure = [_root objectForKey: @"ReturnEnvironmentX"];
    
    id result = [closure callWithThis: otherEnvironment];
    STAssertEqualObjects(result, @6789,
                         @"Squirrel closure should read the value from "
                         @"the environment table passed to it by callWithEnvironment:");
}


#pragma mark -
#pragma mark notifications

- (void) handleClosureCalledNotification: (NSNotification *) notification
{
    _closureCalled = YES;
}

@end
