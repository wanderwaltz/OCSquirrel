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


#pragma mark -
#pragma mark pushing tests

- (void) testPushInteger
{
    [_squirrelVM.stack pushInteger: 12345];
    SQInteger value = 0;
    sq_getinteger(_squirrelVM.vm, -1, &value);
    
    STAssertEquals(value, 12345,
                   @"-pushInteger: should push the expected value to the Squirrel VM stack.");
}


- (void) testPushFloat
{
    [_squirrelVM.stack pushFloat: 123.456];
    SQFloat value = 0.0;
    sq_getfloat(_squirrelVM.vm, -1, &value);
    
    STAssertEquals(value, 123.456f,
                   @"-pushFloat: should push the expected value to the Squirrel VM stack");
}


- (void) testPushBool
{
    [_squirrelVM.stack pushBool: YES];
    SQBool value = SQFalse;
    sq_getbool(_squirrelVM.vm, -1, &value);
    
    STAssertEquals(value, (SQBool)SQTrue,
                   @"-pushBool: should push the expected value to the Squirrel VM stack");
}


- (void) testPushNull
{
    [_squirrelVM.stack pushNull];
    
    STAssertEquals(sq_gettype(_squirrelVM.vm, -1), OT_NULL,
                   @"-pushNull should push `null` value to the Squirrel VM stack.");
}


- (void) testPushUserPointer
{
    [_squirrelVM.stack pushUserPointer: (__bridge SQUserPointer)self];
    
    SQUserPointer pointer = NULL;
    sq_getuserpointer(_squirrelVM.vm, -1, &pointer);
    
    STAssertEquals(pointer, (__bridge SQUserPointer)self,
                   @"-pushUserPointer: should push the expected value to the Squirrel VM stack.");
}


- (void) testPushObject
{
    HSQOBJECT object;
    sq_resetobject(&object);
    
    [_squirrelVM.stack pushSQObject: object];
    
    HSQOBJECT other;
    
    sq_getstackobj(_squirrelVM.vm, -1, &other);
    
    STAssertEquals(object, other,
                   @"-pushSQObject: should push the expected value to the Squirrel VM stack.");
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


#pragma mark -
#pragma mark reading successfull tests

- (void) testIntegerAtPosition
{
    [_squirrelVM.stack pushInteger: 12345];
    STAssertEquals(12345, [_squirrelVM.stack integerAtPosition: -1],
                   @"-integerAtPosition: should return the pushed value.");
}


- (void) testStringAtPosition
{
    // That's the word 'unicode' written with Cyrillic alphabet
    static NSString * const kString = @"юникод";
    
    [_squirrelVM.stack pushString: kString];
    STAssertEqualObjects(kString, [_squirrelVM.stack stringAtPosition: -1],
                         @"-stringAtPosition: should return the pushed value");
}


#pragma mark -
#pragma mark reading failures tests

- (void) testReadIntegerFailure
{
    [_squirrelVM.stack pushString: @"string"];
    STAssertEquals(0, [_squirrelVM.stack integerAtPosition: -1],
                   @"If failed to read an integer, OCSquirrelVMStack is expected to return 0.");
}


- (void) testReadStringFailure
{
    [_squirrelVM.stack pushInteger: 12345];
    STAssertNil([_squirrelVM.stack stringAtPosition: -1],
                @"If failed to read a string, OCSquirrelVMStack is expected to return nil.");
}

@end
