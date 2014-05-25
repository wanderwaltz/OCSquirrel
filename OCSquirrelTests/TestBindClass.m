//
//  TestBindClass.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 4/26/13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#ifndef GHUnit_Target
#import <XCTest/XCTest.h>
#endif

#import <OCSquirrel/OCSquirrel.h>
#import "OCMock.h"
#import "BindingHelperClasses.h"


#pragma mark -
#pragma mark TestBindClass interface

@interface TestBindClass : XCTestCase
{
    OCSquirrelVM *_squirrelVM;
    OCSquirrelTable *_rootTable;
}

@end


#pragma mark -
#pragma mark TestBindClass implementation

@implementation TestBindClass

- (void) setUp
{
    [super setUp];
    _squirrelVM = [[OCSquirrelVM alloc] init];
    _rootTable  = [OCSquirrelTable rootTableForVM: _squirrelVM];
}


- (void) tearDown
{
    _rootTable  = nil;
    _squirrelVM = nil;
    [super tearDown];
}


#pragma mark -
#pragma mark basic tests

- (void) testBindClassExists
{
    XCTAssertTrue([OCSquirrelVM instancesRespondToSelector: @selector(bindClass:)],
                 @"OCSquirrelVM should have a -bindClass: method");
}


- (void) testBindClassNoThrow
{
    XCTAssertNoThrow([_squirrelVM bindClass: [NSDate class]],
                    @"OCSquirrelVM should not throw exception when binding a class");
}


- (void) testDoesCreateSquirrelClass
{
    OCSquirrelClass *class = [_squirrelVM bindClass: [NSDate class]];
    
    XCTAssertNotNil(class,
                   @"bindClass should return an OCSquirrelClass instance");
}


- (void) testBindingTwiceSameClass
{
    OCSquirrelClass *class1 = [_squirrelVM bindClass: [NSDate class]];
    OCSquirrelClass *class2 = [_squirrelVM bindClass: [NSDate class]];
    
    XCTAssertEqualObjects(class1, class2,
                         @"bindClass should return the same OCSquirrelClass "
                         @"for the same Objective-C classes");
}


- (void) testType
{
    OCSquirrelClass *class = [_squirrelVM bindClass: [NSDate class]];
    
    XCTAssertEqual(class.type, OT_CLASS,
                   @"bindClass should return an OCSquirrelObject of type OT_CLASS");
}


- (void) testNativeClassForBoundClass
{
    OCSquirrelClass *class = [_squirrelVM bindClass: [NSDate class]];
    
    XCTAssertEqual(class.nativeClass, [NSDate class],
                   @"OCSquirrelClass instances should have a native class property "
                   @"pointing to the Objective-C class for bound classes.");
}


- (void) testNativeClassForUnboundClass
{
    OCSquirrelClass *class = [[OCSquirrelClass alloc] initWithVM: _squirrelVM];
    
    XCTAssertNil(class.nativeClass,
                 @"OCSquirrelClass instances should have a native class property "
                 @"with nil value for classes not bound with any native Objective-C class");
}


- (void) testSameClassObject
{
    OCSquirrelClass *class = [_squirrelVM bindClass: [NSDate class]];
    
    [class push];
    
    OCSquirrelClass *other = [_squirrelVM.stack valueAtPosition: -1];
    
    XCTAssertEqualObjects(class, other,
                         @"OCSquirrelStack should return the same instance of the bound class "
                         @"as the instance which is returned by bindClass");
}


- (void) testCouldPushNewInstance
{
    OCSquirrelClass *class = [_squirrelVM bindClass: [NSDate class]];
    [class pushNewInstance];
    
    OCSquirrelInstance *instance = [_squirrelVM.stack valueAtPosition: -1];
    
    XCTAssertNotNil(instance,
                   @"OCSquirrelClass should be able to create instances of the bound class.");
}


- (void) testCouldCreateInstance
{    
    OCSquirrelClass *class = [_squirrelVM bindClass: [NSDate class]];
    OCSquirrelTable *root  = [OCSquirrelTable rootTableForVM: _squirrelVM];
    
    [root setObject: class forKey: @"NSDate"];
    
    NSError *error = nil;
    [_squirrelVM execute: @"return NSDate();" error: &error];
    
    XCTAssertNil(error,
                @"Squirrel script should be able to create instances of the bound class.");
}



- (void) testCreateInstanceResultClass
{
    OCSquirrelClass *class = [_squirrelVM bindClass: [NSDate class]];
    OCSquirrelTable *root  = [OCSquirrelTable rootTableForVM: _squirrelVM];
    
    [root setObject: class forKey: @"NSDate"];
    
    NSError *error = nil;
    id result = [_squirrelVM execute: @"return NSDate();" error: &error];
    
    XCTAssertTrue([result isKindOfClass: [OCSquirrelInstance class]],
                @"Creating an instance of a class should return OCSquirrelInstance");
}


- (void) testCreateInstanceResultUP
{
    OCSquirrelClass *class = [_squirrelVM bindClass: [NSDate class]];
    OCSquirrelTable *root  = [OCSquirrelTable rootTableForVM: _squirrelVM];
    
    [root setObject: class forKey: @"NSDate"];
    NSError *error = nil;
    OCSquirrelInstance *instance = [_squirrelVM execute: @"return NSDate();" error: &error];
    
    XCTAssertNotNil(instance.instanceUP,
                   @"Creating an instance of a native bound class should return OCSquirrelInstance "
                   @"with a non-nil instance user pointer.");
}


- (void) testPushNewInstanceResultUP
{
    OCSquirrelClass *class = [_squirrelVM bindClass: [NSDate class]];
    [class pushNewInstance];
    
    OCSquirrelInstance *instance = [_squirrelVM.stack valueAtPosition: -1];
    
    XCTAssertNotNil(instance.instanceUP,
                   @"Creating an instance of a native bound class should return OCSquirrelInstance "
                   @"with a non-nil instance user pointer.");
}


- (void) testPushNewInstanceUPClass
{
    OCSquirrelClass *class = [_squirrelVM bindClass: [NSDate class]];
    [class pushNewInstance];
    
    OCSquirrelInstance *instance = [_squirrelVM.stack valueAtPosition: -1];
    
    XCTAssertTrue([instance.instanceUP isKindOfClass: [NSDate class]],
                 @"Creating an instance of a native bound class should return OCSquirrelInstance "
                 @"with a non-nil instance user pointer of the said native class.");
}


- (void) testBindInitNoError
{
    OCSquirrelClass *class = [_squirrelVM bindClass: [SimpleInvocationChecker class]];
    
    NSError *error = nil;
    [class bindInstanceMethodWithSelector: @selector(init) error: &error];
    
    XCTAssertNil(error,
                @"Should be able to bind -init method.");
}



- (void) testSimpleInvocationIsCalled
{
    OCSquirrelClass *class = [_squirrelVM bindClass: [SimpleInvocationChecker class]];
    [class bindInstanceMethodWithSelector: @selector(init) error: nil];
    
    OCSquirrelTable *root  = [OCSquirrelTable rootTableForVM: _squirrelVM];
    [root setObject: class forKey: @"SimpleInvocationChecker"];
    
    NSError *error = nil;
    OCSquirrelInstance *instance =
    [_squirrelVM execute: @"return SimpleInvocationChecker().init()" error: &error];
    
    XCTAssertTrue([instance.instanceUP calledInit],
                @"Calling init() method from Squirrel should actually invoke -init on the "
                @"corresponding Objective-C object");
}


- (void) testInitMethodReturningNil
{
    OCSquirrelClass *class = [_squirrelVM bindClass: [InitializerChecker class]];
    [class bindInstanceMethodWithSelector: @selector(init) error: nil];
    
    OCSquirrelTable *root  = [OCSquirrelTable rootTableForVM: _squirrelVM];
    [root setObject: class forKey: @"InitializerChecker"];
    
    NSError *error = nil;
    OCSquirrelInstance *instance =
    [_squirrelVM execute: @"return InitializerChecker().init()" error: &error];
    
    XCTAssertNil(instance.instanceUP,
                @"-init method returning a different value for 'self' should actually"
                @"replace the instance user pointer of the Squirrel class instance.");
}


#pragma mark -
#pragma mark simple instance invocations: no parameters

- (void) testSimpleInstanceIntReturnValue
{
    OCSquirrelClass *class = [_squirrelVM bindClass: [SimpleInvocationChecker class]];
    [class bindInstanceMethodWithSelector: @selector(integerMethodNoParams)
                                    error: nil];
    [class pushNewInstance];
    
    OCSquirrelInstance *instance = [_squirrelVM.stack valueAtPosition: -1];
    
    id nativeInstance = instance.instanceUP;
    
    XCTAssertEqualObjects(@([nativeInstance integerMethodNoParams]),
                         [instance callClosureWithKey: @"integerMethodNoParams"],
                         @"Bound class should have a method returning integer and accepting no parameters");
}


- (void) testSimpleInstanceFloatReturnValue
{
    OCSquirrelClass *class = [_squirrelVM bindClass: [SimpleInvocationChecker class]];
    [class bindInstanceMethodWithSelector: @selector(floatMethodNoParams)
                                    error: nil];
    
    [class pushNewInstance];
    
    OCSquirrelInstance *instance = [_squirrelVM.stack valueAtPosition: -1];
    
    id nativeInstance = instance.instanceUP;
    
    XCTAssertEqualObjects(@([nativeInstance floatMethodNoParams]),
                         [instance callClosureWithKey: @"floatMethodNoParams"],
                         @"Bound class should have a method returning float and accepting no parameters");
}


- (void) testSimpleInstanceBOOLReturnValue
{
    OCSquirrelClass *class = [_squirrelVM bindClass: [SimpleInvocationChecker class]];
    [class bindInstanceMethodWithSelector: @selector(boolMethodNoParams)
                                    error: nil];
    
    [class pushNewInstance];
    
    OCSquirrelInstance *instance = [_squirrelVM.stack valueAtPosition: -1];
    
    id nativeInstance = instance.instanceUP;
    
    XCTAssertEqualObjects(@([nativeInstance boolMethodNoParams]),
                         [instance callClosureWithKey: @"boolMethodNoParams"],
                         @"Bound class should have a method returning bool and accepting no parameters");
}


- (void) testSimpleInstanceStringReturnValue
{
    OCSquirrelClass *class = [_squirrelVM bindClass: [SimpleInvocationChecker class]];
    [class bindInstanceMethodWithSelector: @selector(stringMethodNoParams)
                                    error: nil];
    
    [class pushNewInstance];
    
    OCSquirrelInstance *instance = [_squirrelVM.stack valueAtPosition: -1];
    
    id nativeInstance = instance.instanceUP;
    
    XCTAssertEqualObjects([nativeInstance stringMethodNoParams],
                         [instance callClosureWithKey: @"stringMethodNoParams"],
                         @"Bound class should have a method returning string and accepting no parameters");
}


- (void) testSimpleInstanceNilReturnValue
{
    OCSquirrelClass *class = [_squirrelVM bindClass: [SimpleInvocationChecker class]];
    [class bindInstanceMethodWithSelector: @selector(nilMethodNoParams)
                                    error: nil];
    
    [class pushNewInstance];
    
    OCSquirrelInstance *instance = [_squirrelVM.stack valueAtPosition: -1];
    
    XCTAssertNil([instance callClosureWithKey: @"nilMethodNoParams"],
                @"Bound class should have a method returning nil and accepting no parameters");
}


- (void) testSimpleInstanceUserPointerReturnValue
{
    OCSquirrelClass *class = [_squirrelVM bindClass: [SimpleInvocationChecker class]];
    [class bindInstanceMethodWithSelector: @selector(pointerMethodNoParams)
                                    error: nil];
    
    [class pushNewInstance];
    
    OCSquirrelInstance *instance = [_squirrelVM.stack valueAtPosition: -1];
    
    id nativeInstance = instance.instanceUP;
    
    XCTAssertEqual([nativeInstance pointerMethodNoParams],
                   [[instance callClosureWithKey: @"pointerMethodNoParams"] pointerValue],
                   @"Bound class should have a method returning void* and accepting no parameters");
}


#pragma mark -
#pragma mark simple instance invocations: single parameter

- (void) testSimpleInstanceIntReturnParam
{
    OCSquirrelClass *class = [_squirrelVM bindClass: [SimpleInvocationChecker class]];
    [class bindInstanceMethodWithSelector: @selector(integerMethodReturnParam:)
                                    error: nil];
    [class pushNewInstance];
    
    OCSquirrelInstance *instance = [_squirrelVM.stack valueAtPosition: -1];
    
    XCTAssertEqualObjects(@12345,
                         [instance callClosureWithKey: @"integerMethodReturnParam"
                                           parameters: @[@12345]],
                         @"Bound class should have a method returning the single integer parameter");
}


- (void) testSimpleInstanceFloatReturnParam
{
    OCSquirrelClass *class = [_squirrelVM bindClass: [SimpleInvocationChecker class]];
    [class bindInstanceMethodWithSelector: @selector(floatMethodReturnParam:)
                                    error: nil];
    [class pushNewInstance];
    
    OCSquirrelInstance *instance = [_squirrelVM.stack valueAtPosition: -1];
    
    XCTAssertEqualObjects(@123.456f,
                         [instance callClosureWithKey: @"floatMethodReturnParam"
                                           parameters: @[@123.456f]],
                         @"Bound class should have a method returning the signle float parameter");
}


- (void) testSimpleInstanceBOOLReturnParam
{
    OCSquirrelClass *class = [_squirrelVM bindClass: [SimpleInvocationChecker class]];
    [class bindInstanceMethodWithSelector: @selector(boolMethodReturnParam:)
                                    error: nil];
    [class pushNewInstance];
    
    OCSquirrelInstance *instance = [_squirrelVM.stack valueAtPosition: -1];
    
    XCTAssertEqualObjects(@YES,
                         [instance callClosureWithKey: @"boolMethodReturnParam"
                                           parameters: @[@YES]],
                         @"Bound class should have a method returning the single BOOL parameter");
}


- (void) testSimpleInstanceStringReturnParam
{
    OCSquirrelClass *class = [_squirrelVM bindClass: [SimpleInvocationChecker class]];
    [class bindInstanceMethodWithSelector: @selector(stringMethodReturnParam:)
                                    error: nil];
    [class pushNewInstance];
    
    OCSquirrelInstance *instance = [_squirrelVM.stack valueAtPosition: -1];
    
    XCTAssertEqualObjects(@"string",
                         [instance callClosureWithKey: @"stringMethodReturnParam"
                                           parameters: @[@"string"]],
                         @"Bound class should have a method returning the single string parameter");
}



- (void) testSimpleInstanceObjectReturnParam
{
    OCSquirrelClass *class = [_squirrelVM bindClass: [SimpleInvocationChecker class]];
    [class bindInstanceMethodWithSelector: @selector(objectMethodReturnParam:)
                                    error: nil];
    
    [class pushNewInstance];
    
    OCSquirrelInstance *instance = [_squirrelVM.stack valueAtPosition: -1];
    
    XCTAssertEqualObjects(self,
                         // Pointers to a generic Objective-C object are pushed to Squirrel stack
                         // as user pointers, so are returned as NSValues with the corresponding
                         // pointer set as pointerValue.
                         (__bridge id)[[instance callClosureWithKey: @"objectMethodReturnParam"
                                                         parameters: @[self]] pointerValue],
                         @"Bound class should have a method returning the single object parameter");
}


- (void) testSimpleInstanceUserPointerReturnParam
{
    OCSquirrelClass *class = [_squirrelVM bindClass: [SimpleInvocationChecker class]];
    [class bindInstanceMethodWithSelector: @selector(pointerMethodReturnParam:)
                                    error: nil];
    [class pushNewInstance];
    
    OCSquirrelInstance *instance = [_squirrelVM.stack valueAtPosition: -1];
    
    XCTAssertEqual((__bridge void *)self,
                   [[instance callClosureWithKey: @"pointerMethodReturnParam"
                                      parameters: @[[NSValue valueWithPointer: (__bridge void *)self]]] pointerValue],
                   @"Bound class should have a method returning the single void* parameter");
}


#pragma mark -
#pragma mark simple instance initializers: single parameter

- (void) testSimpleInitializerIntParam
{
    OCSquirrelClass *class = [_squirrelVM bindClass: [InitializerChecker class]];
    [class bindInstanceMethodWithSelector: @selector(initWithInt:)
                                    error: nil];
    
    [_rootTable setObject: class forKey: @"InitializerChecker"];
    

    OCSquirrelInstance *instance = [_squirrelVM execute:
                                    @"return InitializerChecker().initWithInt(12345);"
                                                      error: nil];
    
    InitializerChecker *object = instance.instanceUP;
    
    XCTAssertEqual((NSInteger)object.intProperty, (NSInteger)12345,
                   @"Initializer method should exist and accept the int parameter.");
}


- (void) testSimpleInitializerFloatParam
{
    OCSquirrelClass *class = [_squirrelVM bindClass: [InitializerChecker class]];
    [class bindInstanceMethodWithSelector: @selector(initWithFloat:)
                                    error: nil];
    
    [_rootTable setObject: class forKey: @"InitializerChecker"];
    
    
    OCSquirrelInstance *instance = [_squirrelVM execute:
                                    @"return InitializerChecker().initWithFloat(123.456);"
                                                      error: nil];
    
    InitializerChecker *object = instance.instanceUP;
    
    XCTAssertEqualWithAccuracy(object.floatProperty, 123.456f, 1e-3,
                               @"Initializer method should exist and accept the float parameter.");
}


- (void) testSimpleInitializerBoolParam
{
    OCSquirrelClass *class = [_squirrelVM bindClass: [InitializerChecker class]];
    [class bindInstanceMethodWithSelector: @selector(initWithBOOL:)
                                    error: nil];
    
    [_rootTable setObject: class forKey: @"InitializerChecker"];
    
    
    OCSquirrelInstance *instance = [_squirrelVM execute:
                                    @"return InitializerChecker().initWithBOOL(true);"
                                                      error: nil];
    
    InitializerChecker *object = instance.instanceUP;
    
    XCTAssertEqual(object.boolProperty, YES,
                   @"Initializer method should exist and accept the BOOL parameter.");
}


- (void) testSimpleInitializerStringParam
{
    OCSquirrelClass *class = [_squirrelVM bindClass: [InitializerChecker class]];
    [class bindInstanceMethodWithSelector: @selector(initWithString:)
                                    error: nil];
    
    [_rootTable setObject: class forKey: @"InitializerChecker"];
    
    
    OCSquirrelInstance *instance = [_squirrelVM execute:
                                    @"return InitializerChecker().initWithString(\"string\");"
                                                      error: nil];
    
    InitializerChecker *object = instance.instanceUP;
    
    XCTAssertEqualObjects(object.stringProperty, @"string",
                         @"Initializer method should exist and accept the NSString parameter.");
}


- (void) testSimpleInitializerPointerParam
{
    OCSquirrelClass *class = [_squirrelVM bindClass: [InitializerChecker class]];
    [class bindInstanceMethodWithSelector: @selector(initWithPointer:)
                                    error: nil];
    
    [class pushNewInstance];
    
    OCSquirrelInstance *instance = [_squirrelVM.stack valueAtPosition: -1];
    
    [instance callClosureWithKey: @"initWithPointer"
                      parameters: @[[NSValue valueWithPointer: (__bridge void*)self]]];
    
    InitializerChecker *object = instance.instanceUP;
    
    XCTAssertEqual(object.pointerProperty, (__bridge void *)self,
                   @"Initializer method should exist and accept the void* parameter.");
}


@end
