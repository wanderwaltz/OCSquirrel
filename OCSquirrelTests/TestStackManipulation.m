//
//  TestStackManipulation.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 14.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "TestStackManipulation.h"


#pragma mark -
#pragma mark TestStackManipulation implementation

@implementation TestStackManipulation

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


- (void) testHasStackProperty
{
    STAssertNotNil(_squirrelVM.stack,
                   @"OCSquirrelVM class has a stack property.");
}


- (void) testStackConformsTo
{
    STAssertTrue([_squirrelVM.stack conformsToProtocol: @protocol(OCSquirrelVMStack)],
                 @"OCSquirrelVM stack should conform to OCSquirrelVMStack protocol.");
}


- (void) testStackHasTopProperty
{
    STAssertTrue([_squirrelVM.stack respondsToSelector: @selector(top)] &&
                 [_squirrelVM.stack respondsToSelector: @selector(setTop:)],
                 @"OCSquirrelVMStack should have a readwrite top property.");
}


- (void) testInitialTopValueSameAsVM
{
    STAssertEquals(_squirrelVM.stack.top, (NSInteger)sq_gettop(_squirrelVM.vm),
                   @"Initial stack top value of the OCSquirrelVMStack should be the same "
                   @"as the stack top value returned by sq_gettop.");
}


- (void) testTopValueSameAsVMAfterPushingRootTable
{
    sq_pushroottable(_squirrelVM.vm);
    STAssertEquals(_squirrelVM.stack.top, (NSInteger)sq_gettop(_squirrelVM.vm),
                   @"Stack top value of the OCSquirrelVMStack should be the same "
                   @"as the stack top value returned by sq_gettop after pushing "
                   @"the root table to the VM.");
}


- (void) testSetTop
{
    sq_pushroottable(_squirrelVM.vm);
    _squirrelVM.stack.top = 0;
    STAssertEquals(_squirrelVM.stack.top, 0,
                   @"Stack top value of the OCSquirrelVMStack should be equal to 0 after "
                   @"explicitly setting it to this value.");
}


- (void) testPushInteger
{
    [_squirrelVM.stack pushInteger: 12345];
    SQInteger value = 0;
    sq_getinteger(_squirrelVM.vm, -1, &value);
    
    STAssertEquals(value, 12345,
                   @"-pushInteger: should push the expected value to the Squirrel VM stack.");
}


- (void) testPushString
{
    // That's the word 'unicode' written with Cyrillic alphabet
    static NSString * const kString = @"юникод";
    
    [_squirrelVM.stack pushString: kString];
    
    const SQChar *cString = NULL;
    
    sq_getstring(_squirrelVM.vm, -1, &cString);
    
    NSString *readString = [[NSString alloc] initWithCString: cString
                                                    encoding: NSUTF8StringEncoding];
    
    STAssertEqualObjects(kString, readString,
                         @"-pushString: should push the UTF8-encoded string to the Squirrel VM stack");
    
}

@end
