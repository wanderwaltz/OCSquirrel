//
//  TestOCSquirrelTable.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 14.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "TestOCSquirrelTable.h"
#import "AdditionalTestAsserts.h"


#pragma mark -
#pragma mark TestOCSquirrelTable implementation

@implementation TestOCSquirrelTable

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


- (void) testOCSquirrelTableClassExists
{
    XCTAssertTrue([OCSquirrelTable isSubclassOfClass: [OCSquirrelObject class]],
                @"OCSquirrelTable class should exist and be a subclass of OCSquirrelObject");
}


- (void) testRootTable
{
    sq_pushroottable(_squirrelVM.vm);
    
    HSQOBJECT root = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    OCSquirrelTable *table = [OCSquirrelTable rootTableForVM: _squirrelVM];
    
    XCTAssertEqualStructs(*table.obj, root,
                          @"+rootTableForVM: method should return an OCSquirrelTable set to the root "
                          @"talbe of the given VM");
}


- (void) testNewTableWhenInitializingWithVM
{
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithVM: _squirrelVM];
    
    XCTAssertEqual(sq_type(*table.obj), OT_TABLE,
                   @"OCSquirrelTable obj property should be of OT_TABLE type.");
}


- (void) testNotNilWhenInitializingWithTable
{
    sq_pushroottable(_squirrelVM.vm);
    
    HSQOBJECT root = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithHSQOBJECT: root
                                                                   inVM: _squirrelVM];
    
    XCTAssertNotNil(table,
                   @"OCSquirrelTable should support initializing with an existing table HSQOBJECT");
}


- (void) testNilWhenInitializingWithNull
{
    HSQOBJECT obj;
    sq_resetobject(&obj);
    
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithHSQOBJECT: obj
                                                                   inVM: _squirrelVM];
    XCTAssertNil(table,
                @"OCSquirrelTable should return nil when initializing with a `null` HSQOBJECT");
}


#pragma mark -
#pragma mark generic object for key getter tests

- (void) testObjectForIntValueStringKeyClass
{
    sq_newtable(_squirrelVM.vm);
    
    HSQOBJECT sqTable = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    [_squirrelVM.stack pushString: @"someKey"];
    [_squirrelVM.stack pushInteger: 1234];
    
    sq_newslot(_squirrelVM.vm, -3, SQFalse);
    
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithHSQOBJECT: sqTable
                                                                   inVM: _squirrelVM];
    
    XCTAssertTrue([[table objectForKey: @"someKey"] isKindOfClass: [NSNumber class]],
                   @"-objectForKey: should return an NSNumber for integer value");
}


- (void) testObjectForIntValueStringKeyValue
{
    sq_newtable(_squirrelVM.vm);
    
    HSQOBJECT sqTable = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    [_squirrelVM.stack pushString: @"someKey"];
    [_squirrelVM.stack pushInteger: 1234];
    
    sq_newslot(_squirrelVM.vm, -3, SQFalse);
    
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithHSQOBJECT: sqTable
                                                                   inVM: _squirrelVM];
    
    XCTAssertEqual([[table objectForKey: @"someKey"] integerValue], 1234,
                 @"-objectForKey: should return the appropriate NSNumber for integer value");
}


- (void) testObjectForFloatValueStringKeyClass
{
    sq_newtable(_squirrelVM.vm);
    
    HSQOBJECT sqTable = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    [_squirrelVM.stack pushString: @"someKey"];
    [_squirrelVM.stack pushFloat: 123.456];
    
    sq_newslot(_squirrelVM.vm, -3, SQFalse);
    
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithHSQOBJECT: sqTable
                                                                   inVM: _squirrelVM];
    
    XCTAssertTrue([[table objectForKey: @"someKey"] isKindOfClass: [NSNumber class]],
                 @"-objectForKey: should return an NSNumber for float value");
}


- (void) testObjectForFloatValueStringKeyValue
{
    sq_newtable(_squirrelVM.vm);
    
    HSQOBJECT sqTable = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    [_squirrelVM.stack pushString: @"someKey"];
    [_squirrelVM.stack pushFloat: 123.456];
    
    sq_newslot(_squirrelVM.vm, -3, SQFalse);
    
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithHSQOBJECT: sqTable
                                                                   inVM: _squirrelVM];
    
    XCTAssertEqual([[table objectForKey: @"someKey"] floatValue], 123.456f,
                   @"-objectForKey: should return the appropriate NSNumber for float value");
}


- (void) testObjectForBoolValueStringKeyClass
{
    sq_newtable(_squirrelVM.vm);
    
    HSQOBJECT sqTable = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    [_squirrelVM.stack pushString: @"someKey"];
    [_squirrelVM.stack pushBool: YES];
    
    sq_newslot(_squirrelVM.vm, -3, SQFalse);
    
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithHSQOBJECT: sqTable
                                                                   inVM: _squirrelVM];
    
    XCTAssertTrue([[table objectForKey: @"someKey"] isKindOfClass: [NSNumber class]],
                 @"-objectForKey: should return an NSNumber for BOOL value");
}


- (void) testObjectForBoolValueStringKeyValue
{
    sq_newtable(_squirrelVM.vm);
    
    HSQOBJECT sqTable = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    [_squirrelVM.stack pushString: @"someKey"];
    [_squirrelVM.stack pushBool: YES];
    
    sq_newslot(_squirrelVM.vm, -3, SQFalse);
    
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithHSQOBJECT: sqTable
                                                                   inVM: _squirrelVM];
    
    XCTAssertEqual([[table objectForKey: @"someKey"] boolValue], YES,
                   @"-objectForKey: should return the appropriate NSNumber for BOOL value");
}


- (void) testObjectForStringValueStringKeyClass
{
    sq_newtable(_squirrelVM.vm);
    
    HSQOBJECT sqTable = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    [_squirrelVM.stack pushString: @"someKey"];
    [_squirrelVM.stack pushString: @"someValue"];
    
    sq_newslot(_squirrelVM.vm, -3, SQFalse);
    
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithHSQOBJECT: sqTable
                                                                   inVM: _squirrelVM];
    
    XCTAssertTrue([[table objectForKey: @"someKey"] isKindOfClass: [NSString class]],
                 @"-objectForKey: should return an NSString for string value");
}


- (void) testObjectForStringValueStringKeyValue
{
    sq_newtable(_squirrelVM.vm);
    
    HSQOBJECT sqTable = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    [_squirrelVM.stack pushString: @"someKey"];
    [_squirrelVM.stack pushString: @"someValue"];
    
    sq_newslot(_squirrelVM.vm, -3, SQFalse);
    
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithHSQOBJECT: sqTable
                                                                   inVM: _squirrelVM];
    
    XCTAssertEqualObjects([table objectForKey: @"someKey"], @"someValue",
                         @"-objectForKey: should return the appropriate NSString for string value");
}


- (void) testObjectForUserPointerValueStringKeyClass
{
    sq_newtable(_squirrelVM.vm);
    
    HSQOBJECT sqTable = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    [_squirrelVM.stack pushString: @"someKey"];
    [_squirrelVM.stack pushUserPointer: (__bridge SQUserPointer)self];
    
    sq_newslot(_squirrelVM.vm, -3, SQFalse);
    
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithHSQOBJECT: sqTable
                                                                   inVM: _squirrelVM];
    
    XCTAssertTrue([[table objectForKey: @"someKey"] isKindOfClass: [NSValue class]],
                 @"-objectForKey: should return an NSValue for userPointer value");
}


- (void) testObjectForUserPointerValueStringKeyValue
{
    sq_newtable(_squirrelVM.vm);
    
    HSQOBJECT sqTable = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    [_squirrelVM.stack pushString: @"someKey"];
    [_squirrelVM.stack pushUserPointer: (__bridge SQUserPointer)self];
    
    sq_newslot(_squirrelVM.vm, -3, SQFalse);
    
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithHSQOBJECT: sqTable
                                                                   inVM: _squirrelVM];
    
    XCTAssertEqual([[table objectForKey: @"someKey"] pointerValue], (__bridge void *)self,
                   @"-objectForKey: should return the appropriate NSValue for userPointer value");
}


- (void) testObjectForNullValueStringKey
{
    sq_newtable(_squirrelVM.vm);
    
    HSQOBJECT sqTable = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    [_squirrelVM.stack pushString: @"someKey"];
    [_squirrelVM.stack pushNull];
    
    sq_newslot(_squirrelVM.vm, -3, SQFalse);
    
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithHSQOBJECT: sqTable
                                                                   inVM: _squirrelVM];
    
    XCTAssertNil([table objectForKey: @"someKey"],
                 @"-objectForKey: should return nil for `null` value");
}


- (void) testObjectForUndefinedKey
{
    sq_newtable(_squirrelVM.vm);
    
    HSQOBJECT sqTable = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    [_squirrelVM.stack pushString: @"someKey"];
    [_squirrelVM.stack pushInteger: 1234];
    
    sq_newslot(_squirrelVM.vm, -3, SQFalse);
    
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithHSQOBJECT: sqTable
                                                                   inVM: _squirrelVM];
    
    XCTAssertNil([table objectForKey: @"undefinedKey"],
                @"-objectForKey: should return nil for undefined key");
}


#pragma mark -
#pragma mark type-specific getter tests

- (void) testIntForStringKey
{
    sq_newtable(_squirrelVM.vm);
    
    HSQOBJECT sqTable = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    [_squirrelVM.stack pushString: @"someKey"];
    [_squirrelVM.stack pushInteger: 1234];
    
    sq_newslot(_squirrelVM.vm, -3, SQFalse);
    
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithHSQOBJECT: sqTable
                                                                   inVM: _squirrelVM];
    
    XCTAssertEqual([table integerForKey: @"someKey"], 1234,
                   @"The value set through Squirrel API should be accessible "
                   @"using OCSquirrelTable methods");
}


- (void) testIntForIntKey
{
    sq_newtable(_squirrelVM.vm);
    
    HSQOBJECT sqTable = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    [_squirrelVM.stack pushInteger: 5678];
    [_squirrelVM.stack pushInteger: 1234];
    
    sq_newslot(_squirrelVM.vm, -3, SQFalse);
    
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithHSQOBJECT: sqTable
                                                                   inVM: _squirrelVM];
    
    XCTAssertEqual([table integerForKey: @5678], 1234,
                   @"The value set through Squirrel API should be accessible "
                   @"using OCSquirrelTable methods");
}


- (void) testFloatForStringKey
{
    sq_newtable(_squirrelVM.vm);
    
    HSQOBJECT sqTable = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    [_squirrelVM.stack pushString: @"someKey"];
    [_squirrelVM.stack pushFloat: 123.456];
    
    sq_newslot(_squirrelVM.vm, -3, SQFalse);
    
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithHSQOBJECT: sqTable
                                                                   inVM: _squirrelVM];
    
    XCTAssertEqual([table floatForKey: @"someKey"], 123.456f,
                   @"The value set through Squirrel API should be accessible "
                   @"using OCSquirrelTable methods");
}


- (void) testBoolForStringKey
{
    sq_newtable(_squirrelVM.vm);
    
    HSQOBJECT sqTable = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    [_squirrelVM.stack pushString: @"someKey"];
    [_squirrelVM.stack pushBool: YES];
    
    sq_newslot(_squirrelVM.vm, -3, SQFalse);
    
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithHSQOBJECT: sqTable
                                                                   inVM: _squirrelVM];
    
    XCTAssertEqual([table boolForKey: @"someKey"], YES,
                   @"The value set through Squirrel API should be accessible "
                   @"using OCSquirrelTable methods");
}


- (void) testStringForStringKey
{
    sq_newtable(_squirrelVM.vm);
    
    HSQOBJECT sqTable = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    [_squirrelVM.stack pushString: @"someKey"];
    [_squirrelVM.stack pushString: @"someValue"];
    
    sq_newslot(_squirrelVM.vm, -3, SQFalse);
    
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithHSQOBJECT: sqTable
                                                                   inVM: _squirrelVM];
    
    XCTAssertEqualObjects([table stringForKey: @"someKey"], @"someValue",
                         @"The value set through Squirrel API should be accessible "
                         @"using OCSquirrelTable methods");
}


- (void) testUserPointerForStringKey
{
    sq_newtable(_squirrelVM.vm);
    
    HSQOBJECT sqTable = [_squirrelVM.stack sqObjectAtPosition: -1];
    
    [_squirrelVM.stack pushString: @"someKey"];
    [_squirrelVM.stack pushUserPointer: (__bridge SQUserPointer)self];
    
    sq_newslot(_squirrelVM.vm, -3, SQFalse);
    
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithHSQOBJECT: sqTable
                                                                   inVM: _squirrelVM];
    
    XCTAssertEqual([table userPointerForKey: @"someKey"], (__bridge SQUserPointer)self,
                   @"The value set through Squirrel API should be accessible "
                   @"using OCSquirrelTable methods");
}


#pragma mark -
#pragma mark generic setter tests

- (void) testSetObjectIntForKeyOnce
{
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithVM: _squirrelVM];
    
    [table setObject: @1234 forKey: @"key"];
    
    XCTAssertEqual([table integerForKey: @"key"], 1234,
                   @"Integer value should be properly set by setObject:forKey:");
}


- (void) testSetObjectIntForKeyTwice
{
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithVM: _squirrelVM];
    
    [table setObject: @1234 forKey: @"key"];
    [table setObject: @5678 forKey: @"key"];
    
    XCTAssertEqual([table integerForKey: @"key"], 5678,
                   @"Should be able to reassign the value for the same key");
}


- (void) testSetObjectFloatForKey
{
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithVM: _squirrelVM];
    
    [table setObject: @123.456 forKey: @"key"];
    
    XCTAssertEqual([table floatForKey: @"key"], 123.456f,
                   @"Float value should be properly set by setObject:forKey:");
}


- (void) testSetObjectBoolForKey
{
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithVM: _squirrelVM];
    
    [table setObject: @YES forKey: @"key"];
    
    XCTAssertEqual([table boolForKey: @"key"], YES,
                   @"Bool value should be properly set by setObject:forKey:");
}


- (void) testSetObjectUserPointerForKey
{
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithVM: _squirrelVM];
    
    [table setObject: [NSValue valueWithPointer: (__bridge void *)self] forKey: @"key"];
    
    XCTAssertEqual([table userPointerForKey: @"key"], (__bridge SQUserPointer)self,
                   @"UserPoniter value should be properly set by setObject:forKey:");
}


- (void) testSetObjectStringForKey
{
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithVM: _squirrelVM];
    
    [table setObject: @"value" forKey: @"key"];
    
    XCTAssertEqualObjects([table stringForKey: @"key"], @"value",
                         @"String value should be properly set by setObject:forKey:");
}


- (void) testSetObjectNilForKey
{
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithVM: _squirrelVM];
    
    [table setObject: nil forKey: @"key"];
    
    XCTAssertNil([table objectForKey: @"key"],
                @"nil value should be properly set by setObject:forKey:");
}


#pragma mark -
#pragma mark type-specific setters

- (void) testSetIntegerForKey
{
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithVM: _squirrelVM];
    [table setInteger: 1234 forKey: @"key"];
    
    XCTAssertEqual([table integerForKey: @"key"], 1234,
                   @"Integer value should be properly set by a type-specific method");
}


- (void) testSetFloatForKey
{
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithVM: _squirrelVM];
    [table setFloat: 123.456 forKey: @"key"];
    
    XCTAssertEqual([table floatForKey: @"key"], 123.456f,
                   @"Float value should be properly set by a type-specific method");
}


- (void) testSetBoolForKey
{
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithVM: _squirrelVM];
    [table setBool: YES forKey: @"key"];
    
    XCTAssertEqual([table boolForKey: @"key"], YES,
                   @"Bool value should be properly set by a type-specific method");
}


- (void) testSetUserPointerForKey
{
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithVM: _squirrelVM];
    [table setUserPointer: (__bridge SQUserPointer)self forKey: @"key"];
    
    XCTAssertEqual([table userPointerForKey: @"key"], (__bridge SQUserPointer)self,
                   @"UserPointer value should be properly set by a type-specific method");
}


- (void) testSetStringForKey
{
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithVM: _squirrelVM];
    [table setString: @"value" forKey: @"key"];
    
    XCTAssertEqualObjects([table stringForKey: @"key"], @"value",
                         @"String value should be properly set by a type-specific method");
}

@end
