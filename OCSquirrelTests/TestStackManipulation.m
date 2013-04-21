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


- (void) testPushValueInteger
{
    [_squirrelVM.stack pushValue: @(1234)];
    
    SQInteger value = 0;
    
    sq_getinteger(_squirrelVM.vm, -1, &value);
    
    STAssertEquals(value, 1234,
                   @"-pushValue: should be capable of pushing integer NSNumbers");
}


- (void) testPushValueFloat
{
    [_squirrelVM.stack pushValue: @(123.456)];
    
    SQFloat value = 0;
    
    sq_getfloat(_squirrelVM.vm, -1, &value);
    
    STAssertEquals(value, 123.456f,
                   @"-pushValue: should be capable of pushing float NSNumbers");
}


- (void) testPushValueBOOL
{
    [_squirrelVM.stack pushValue: @YES];
    
    SQBool value = SQFalse;
    
    sq_getbool(_squirrelVM.vm, -1, &value);
    
    STAssertEquals(value, (SQBool)SQTrue,
                   @"-pushValue: should be capable of pushing BOOL NSNumbers");
}


- (void) testPushValueBoolLikeYES
{
    [_squirrelVM.stack pushValue: @((SQInteger)YES)];
    
    SQInteger value = 0;
    
    sq_getinteger(_squirrelVM.vm, -1, &value);
    
    STAssertEquals(value, (SQInteger)YES,
                   @"-pushValue: should not confuse (SQInteger)YES integers with BOOL YES values");
}


- (void) testPushValueBoolLikeNO
{
    [_squirrelVM.stack pushValue: @((SQInteger)NO)];
    
    SQInteger value = 0;
    
    sq_getinteger(_squirrelVM.vm, -1, &value);
    
    STAssertEquals(value, (SQInteger)NO,
                   @"-pushValue: should not confuse (SQInteger)NO integers with BOOL NO values");
}


- (void) testPushValueString
{
    // That's the word 'unicode' written with Cyrillic alphabet
    static NSString * const kString = @"юникод";
    
    [_squirrelVM.stack pushValue: kString];
    
    const SQChar *cString = NULL;
    
    sq_getstring(_squirrelVM.vm, -1, &cString);
    
    NSString *readString = [[NSString alloc] initWithCString: cString
                                                    encoding: NSUTF8StringEncoding];
    
    STAssertEqualObjects(kString, readString,
                         @"-pushValue: should be capable of pushing NSStrings");
    
}


- (void) testPushValueNil
{
    // Pushing root table so that the stack is not empty;
    // otherwise the test would falsely pass even if there
    // is no `null` at the top.
    sq_pushroottable(_squirrelVM.vm);
    
    [_squirrelVM.stack pushValue: nil];
    STAssertTrue([_squirrelVM.stack isNullAtPosition: -1],
                 @"-pushValue: should push `null` for nil value");
}


- (void) testPushValueNSNull
{
    // Pushing root table so that the stack is not empty;
    // otherwise the test would falsely pass even if there
    // is no `null` at the top.
    sq_pushroottable(_squirrelVM.vm);
    
    [_squirrelVM.stack pushValue: [NSNull null]];
    STAssertTrue([_squirrelVM.stack isNullAtPosition: -1],
                 @"-pushValue: should push `null` for nil value");
}


- (void) testPushValuePointer
{
    [_squirrelVM.stack pushValue: [NSValue valueWithPointer: (__bridge void *)self]];
    STAssertEquals([_squirrelVM.stack userPointerAtPosition: -1], (__bridge SQUserPointer)self,
                   @"-pushValue: should be capable of pushing NSValues with pointers");
}


- (void) testThrowsForUnsupportedTypes
{
    STAssertThrowsSpecificNamed([_squirrelVM.stack pushValue: [NSObject new]],
                                NSException, NSInvalidArgumentException,
                                @"-pushValue: shoud throw an NSInvalidArgumentException for unsupported "
                                @"values.");
}


#pragma mark -
#pragma mark reading successfull tests

- (void) testIntegerAtPosition
{
    [_squirrelVM.stack pushInteger: 12345];
    STAssertEquals(12345, [_squirrelVM.stack integerAtPosition: -1],
                   @"-integerAtPosition: should return the pushed value.");
}


- (void) testFloatAtPosition
{
    [_squirrelVM.stack pushFloat: 123.456];
    STAssertEquals(123.456f, [_squirrelVM.stack floatAtPosition: -1],
                   @"-floatAtPosition: should return the pushed value.");
}


- (void) testBoolAtPosition
{
    [_squirrelVM.stack pushBool: YES];
    STAssertEquals(YES, [_squirrelVM.stack boolAtPosition: -1],
                   @"-boolAtPosition: should return the pushed value.");
}


- (void) testUserPointerAtPosition
{
    [_squirrelVM.stack pushUserPointer: (__bridge SQUserPointer)self];
    
    STAssertEquals((__bridge SQUserPointer)self, [_squirrelVM.stack userPointerAtPosition: -1],
                   @"-userPointerAtPosition: should return the pushed value");
}


- (void) testSQObjectAtPosition
{
    sq_pushroottable(_squirrelVM.vm);
    
    HSQOBJECT root;
    
    sq_getstackobj(_squirrelVM.vm, -1, &root);
    
    [_squirrelVM.stack pushSQObject: root];
    
    STAssertEquals(root, [_squirrelVM.stack sqObjectAtPosition: -1],
                   @"-sqObjectAtPosition: should return the pushed value");
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
#pragma mark reading generic values

- (void) testReadValueIntegerClass
{
    [_squirrelVM.stack pushInteger: 1234];
    STAssertTrue([[_squirrelVM.stack valueAtPosition: -1] isKindOfClass: [NSNumber class]],
                 @"-valueAtPosition: should return an NSNumber for integer stack values");
}


- (void) testReadValueIntegerValue
{
    [_squirrelVM.stack pushInteger: 1234];
    STAssertEquals([[_squirrelVM.stack valueAtPosition: -1] integerValue], 1234,
                 @"-valueAtPosition: should return the corresponding NSNumber for integer stack values");
}


- (void) testReadValueFloatClass
{
    [_squirrelVM.stack pushFloat: 123.456];
    STAssertTrue([[_squirrelVM.stack valueAtPosition: -1] isKindOfClass: [NSNumber class]],
                 @"-valueAtPosition: should return an NSNumber for float stack values");
}


- (void) testReadValueFloatValue
{
    [_squirrelVM.stack pushFloat: 123.456];
    STAssertEquals([[_squirrelVM.stack valueAtPosition: -1] floatValue], 123.456f,
                   @"-valueAtPosition: should return the corresponding NSNumber for float stack values");
}


- (void) testReadValueBoolClass
{
    [_squirrelVM.stack pushBool: YES];
    STAssertTrue([[_squirrelVM.stack valueAtPosition: -1] isKindOfClass: [NSNumber class]],
                 @"-valueAtPosition: should return an NSNumber for bool stack values");
}


- (void) testReadValueBoolValue
{
    [_squirrelVM.stack pushBool: YES];
    STAssertEquals([[_squirrelVM.stack valueAtPosition: -1] boolValue], YES,
                   @"-valueAtPosition: should return the corresponding NSNumber for bool stack values");
}


- (void) testReadValueUserPointerClass
{
    [_squirrelVM.stack pushUserPointer: (__bridge SQUserPointer)self];
    STAssertTrue([[_squirrelVM.stack valueAtPosition: -1] isKindOfClass: [NSValue class]],
                 @"-valueAtPosition: should return an NSValue for userPointer stack values");
}


- (void) testReadValueUserPointerValue
{
    [_squirrelVM.stack pushUserPointer: (__bridge SQUserPointer)self];
    STAssertEquals([[_squirrelVM.stack valueAtPosition: -1] pointerValue], (__bridge void *)self,
                   @"-valueAtPosition: should return the corresponding NSValue for userPointer stack values");
}


- (void) testReadValueStringClass
{
    [_squirrelVM.stack pushString: @"qwerty"];
    STAssertTrue([[_squirrelVM.stack valueAtPosition: -1] isKindOfClass: [NSString class]],
                 @"-valueAtPosition: should return an NSString for string stack values");
}


- (void) testReadValueStringValue
{
    [_squirrelVM.stack pushString: @"qwerty"];
    STAssertEqualObjects([_squirrelVM.stack valueAtPosition: -1], @"qwerty",
                   @"-valueAtPosition: should return the corresponding NSString for string stack values");
}


- (void) testReadValueNullValue
{
    [_squirrelVM.stack pushNull];
    STAssertNil([_squirrelVM.stack valueAtPosition: -1],
                @"-valueAtPosition: should return nil for `null` values");
}


- (void) testReadValueTableClass
{
    sq_pushroottable(_squirrelVM.vm);
    STAssertTrue([[_squirrelVM.stack valueAtPosition: -1] isKindOfClass: [OCSquirrelTable class]],
                 @"-valueAtPosition: should return an OCSquirrelTable for table stack values");
}


- (void) testReadValueTableValue
{
    sq_pushroottable(_squirrelVM.vm);
    
    HSQOBJECT root = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    STAssertEquals(*[[_squirrelVM.stack valueAtPosition: -1] obj], root,
                   @"-valueAtPosition: should return the corresponding OCSquirrelTable for "
                   @"table stack values");
}


- (void) testReadValueOtherClass
{
    sq_newuserdata(_squirrelVM.vm, 1);
    STAssertTrue([[_squirrelVM.stack valueAtPosition: -1] isKindOfClass: [OCSquirrelObject class]],
                 @"-valueAtPosition: should return an OCSquirrelObject for other stack values");
}


- (void) testReadValueOtherValue
{
    sq_newuserdata(_squirrelVM.vm, 1);
    
    HSQOBJECT object = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    STAssertEquals(*[[_squirrelVM.stack valueAtPosition: -1] obj], object,
                   @"-valueAtPosition: should return the corresponding OCSquirrelObject for "
                   @"other stack values");
}


#pragma mark -
#pragma mark reading failures tests

- (void) testReadIntegerFailure
{
    [_squirrelVM.stack pushString: @"string"];
    STAssertEquals(0, [_squirrelVM.stack integerAtPosition: -1],
                   @"If failed to read an integer, OCSquirrelVMStack is expected to return 0.");
}


- (void) testReadFloatFailure
{
    [_squirrelVM.stack pushNull];
    STAssertEquals([_squirrelVM.stack floatAtPosition: -1], 0.0f,
                @"If failed to read a float, OCSquirrelVMStack is expected to return 0.0");
}


- (void) testReadBoolFailure
{
    [_squirrelVM.stack pushNull];
    STAssertEquals([_squirrelVM.stack boolAtPosition: -1], NO,
                   @"If failed to read a BOOL, OCSquirrelVMStack is expected to return NO");
}


- (void) testReadUserPointerFailure
{
    [_squirrelVM.stack pushString: @"qwerty"];
    STAssertEquals([_squirrelVM.stack userPointerAtPosition: -1], NULL,
                   @"If failed to read a SQUserPointer, OCSquirrelVMStack is expected to return NULL");
}


- (void) testReadStringFailure
{
    [_squirrelVM.stack pushInteger: 12345];
    STAssertNil([_squirrelVM.stack stringAtPosition: -1],
                @"If failed to read a string, OCSquirrelVMStack is expected to return nil.");
}


#pragma mark -
#pragma mark type information

- (void) testIsNullAtPosition
{
    [_squirrelVM.stack pushNull];
    STAssertTrue([_squirrelVM.stack isNullAtPosition: -1],
                 @"-isNullAtPosition: should be YES for `null` values pushed to stack.");
}

@end
