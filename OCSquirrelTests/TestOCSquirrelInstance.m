//
//  TestOCSquirrelInstance.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 04.05.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "TestOCSquirrelInstance.h"


#pragma mark -
#pragma mark TestOCSquirrelInstance implementation

@implementation TestOCSquirrelInstance

- (void) setUp
{
    [super setUp];
    _squirrelVM = [[OCSquirrelVM alloc] init];
    _instance   = [_squirrelVM executeSync:
     @"class Test {                                     \
         memberInt    = 12345;                          \
         memberFloat  = 123.456;                        \
         memberBool   = true;                           \
         memberString = \"string\";                     \
                                                        \
         function functionInt()    { return 12345;    } \
         function functionFloat()  { return 123.456;  } \
         function functionBool()   { return true;     } \
         function functionString() { return \"string\"} \
     } return Test();"
                       error: nil];
}


- (void) tearDown
{
    _squirrelVM = nil;
    [super tearDown];
}


#pragma mark -
#pragma mark basic tests

- (void) testCouldCreateInstance
{
    id instance = [_squirrelVM executeSync: @"return Test()" error: nil];
    
    STAssertTrue([instance isKindOfClass: [OCSquirrelInstance class]],
                 @"Should be able to create instances of the class declared in setUp method.");
}


- (void) testCaseProperlySetUp
{
    STAssertTrue([_instance isKindOfClass: [OCSquirrelInstance class]],
                 @"setUp method should have created an instance of the class");
}


#pragma mark -
#pragma mark member access tests

- (void) testGetIvarInt
{
    STAssertEqualObjects([_instance objectForKey: @"memberInt"], @12345,
                         @"Should be able to access Squirrel class instance member of int type");
}


- (void) testGetIvarFloat
{
    STAssertEqualsWithAccuracy([[_instance objectForKey: @"memberFloat"] floatValue], 123.456f, 1e-3,
                         @"Should be able to access Squirrel class instance member of float type");
}


- (void) testGetIvarBool
{
    STAssertEqualObjects([_instance objectForKey: @"memberBool"], @YES,
                         @"Should be able to access Squirrel class instance member of bool type");
}


- (void) testGetIvarString
{
    STAssertEqualObjects([_instance objectForKey: @"memberString"], @"string",
                         @"Should be able to access Squirrel class instance member of string type");
}

#pragma mark -
#pragma mark calls tests

- (void) testCallMethodResultInt
{
    STAssertEqualObjects([_instance callClosureWithKey: @"functionInt"], @12345,
                         @"Should be able to call Squirrel class instance method with int return type");
}


- (void) testCallMethodResultFloat
{
    STAssertEqualsWithAccuracy([[_instance callClosureWithKey: @"functionFloat"] floatValue], 123.456f, 1e-3,
                         @"Should be able to call Squirrel class instance method with float return type");
}


- (void) testCallMethodResultBool
{
    STAssertEqualObjects([_instance callClosureWithKey: @"functionBool"], @YES,
                         @"Should be able to call Squirrel class instance method with bool return type");
}


- (void) testCallMethodResultString
{
    STAssertEqualObjects([_instance callClosureWithKey: @"functionString"], @"string",
                         @"Should be able to call Squirrel class instance method with string return type");
}


@end
