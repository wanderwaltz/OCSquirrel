//
//  TestOCSquirrelVM.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 13.04.13.
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

#import <math.h>
#import <stdlib.h>
#import "sqvm.h"
#import "sqobject.h"
#import "squtils.h"
#import "sqpcheader.h"
#import "sqopcodes.h"
#import "sqvm.h"
#import "sqfuncproto.h"
#import "sqclosure.h"
#import "sqstring.h"
#import "sqtable.h"
#import "squserdata.h"
#import "sqarray.h"
#import "sqclass.h"

#pragma mark -
#pragma mark TestOCSquirrelVM interface

@interface TestOCSquirrelVM : XCTestCase
{
    OCSquirrelVM *_squirrelVM;
}

@end


#pragma mark -
#pragma mark OCSquirrelVMInitWithStackSizeOverride class

/*! A custom OCSquirrelVM subclass which sets the calledInitWithStackSize property to YES 
    if -initWithStackSize: method has been called with the kOCSquirrelVMDefaultInitialStackSize 
    constant as parameter.
 
 This class is used for testing that the default initializer calls the designated initializer.
 */
@interface OCSquirrelVMInitWithStackSizeOverride : OCSquirrelVM
@property (readonly, nonatomic) BOOL calledInitWithStackSize;
@end

@implementation OCSquirrelVMInitWithStackSizeOverride : OCSquirrelVM

- (id) initWithStackSize: (NSUInteger) stackSize
{
    self = [super initWithStackSize: stackSize];
    
    if (self != nil)
    {
        if (stackSize == kOCSquirrelVMDefaultInitialStackSize)
            _calledInitWithStackSize = YES;
    }
    return self;
}

@end


#pragma mark -
#pragma mark TestOCSquirrelVM implementation

@implementation TestOCSquirrelVM

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


#pragma mark -
#pragma mark tests for general properties of the VM

- (void) testCreation
{
    XCTAssertNotNil(_squirrelVM,
                   @"OCSquirrelVM class should be created");
}


- (void) testHasVMProperty
{
    __block BOOL hasVM = NO;
    
    [_squirrelVM perform:^(HSQUIRRELVM vm, id<OCSquirrelVMStack> stack) {
        hasVM = (vm != NULL);
    }];
    
    XCTAssertTrue(hasVM, @"OCSquirrelVM should have a non-nil vm property.");
}


- (void) testForeignPtr
{
    __block SQUserPointer vmPointer = NULL;
    
    [_squirrelVM perform:^(HSQUIRRELVM vm, id<OCSquirrelVMStack> stack) {
        vmPointer = sq_getforeignptr(vm);
    }];

    XCTAssertEqual(vmPointer, (__bridge SQUserPointer)_squirrelVM,
                   @"OCSquirrelVM should set self as the foreign ptr for the Squirrel VM");
}


- (void) testDefaultInitialStackSize
{
    __block NSUInteger capacity = 0;
    
    [_squirrelVM perform:^(HSQUIRRELVM vm, id<OCSquirrelVMStack> stack) {
        capacity = vm->_stack.capacity();
    }];
    
    XCTAssertEqual(capacity, kOCSquirrelVMDefaultInitialStackSize,
                   @"Initial stack size of a OCSquirrelVM initialized with -init should be equal to "
                   @"kOCSquirrelVMDefaultInitialStackSize");
}


- (void) testCustomInitialStackSize
{
    static const NSUInteger kCustomStackSize = 10;
    
    __block NSUInteger capacity = 0;
    
    _squirrelVM = [[OCSquirrelVM alloc] initWithStackSize: kCustomStackSize];
    
    [_squirrelVM perform:^(HSQUIRRELVM vm, id<OCSquirrelVMStack> stack) {
        capacity = vm->_stack.capacity();
    }];
    
    XCTAssertEqual(capacity, kCustomStackSize,
                   @"Initial stack size of a OCSquirrelVM initialized with -initWithStackSize: "
                   @"should be equal to kCustomStackSize");
}


- (void) testInitCallsInitWithStackSize
{
    // A custom OCSquirrelVM subclass which sets the calledInitWithStackSize
    // property to YES if -initWithStackSize: method has been called with
    // the kOCSquirrelVMDefaultInitialStackSize constant as parameter.
    OCSquirrelVMInitWithStackSizeOverride *vm = [OCSquirrelVMInitWithStackSizeOverride new];
    
    XCTAssertTrue(vm.calledInitWithStackSize,
                 @"-init method should have called -initWithStackSize: with "
                 @"kOCSquirrelVMDefaultInitialStackSize param value");
}


- (void) testHasDelegateProperty
{
    XCTAssertTrue([OCSquirrelVM instancesRespondToSelector: @selector(setDelegate:)] &&
                 [OCSquirrelVM instancesRespondToSelector: @selector(delegate)],
                 @"OCSquirrelVM should have a readwrite delegate property");
}


- (void) testThrowsIfDelegateWrongProtocol
{
    XCTAssertThrowsSpecificNamed(_squirrelVM.delegate = (id)[NSObject new],
                                NSException, NSInvalidArgumentException,
                                @"OCSquirrelVM should throw and NSIvalidArgumentException if a delegate "
                                @"not conforming to OCSquirrelVMDelegate protocol is set.");
}


- (void) testDoesNotThrowIfDelegateRightProtocol
{
    id delegate = [OCMockObject mockForProtocol: @protocol(OCSquirrelVMDelegate)];
    
    XCTAssertNoThrow(_squirrelVM.delegate = delegate,
                    @"OCSquirrelVM does not throw an exception if a delegate conforming to "
                    @"OCSquireelVMDelegate protocol is set.");
}


#pragma mark -
#pragma mark executeSync: errors

- (void) testExecuteSyncValidNoThrow
{
    XCTAssertNoThrow([_squirrelVM execute: @"local x = 0;" error: nil],
                    @"OCSquirrelVM -executeSync: should not throw exception for a valid Squirrel script.");
}


- (void) testExecuteSyncInvalidError
{
    NSError *error = nil;
    [_squirrelVM execute: @"local x + 0" error: &error];
    
    XCTAssertNotNil(error,
                   @"OCSquirrelVM -executeSync: should return a not nil NSError "
                   @"for an invalid Squirrel script.");
}


- (void) testExecuteSyncInvalidLastError
{
    NSError *error = nil;
    [_squirrelVM execute: @"local x + 0" error: &error];
    
    XCTAssertEqualObjects(error, _squirrelVM.lastError,
                         @"OCSquirrelVM -executeSync: should return a not nil NSError "
                         @"and have a lastError property with the same error.");
}


- (void) testExecuteSyncInvalidErrorDomain
{
    NSError *error = nil;
    [_squirrelVM execute: @"local x + 0" error: &error];
    
    XCTAssertEqualObjects(error.domain, OCSquirrelVMErrorDomain,
                         @"Error returned by OCSquirrelVM should have OCSquirrelVMErrorDomain domain.");
}


- (void) testExecuteSyncInvalidErrorCodeFailedGetCString
{
    NSError *error = nil;
    [_squirrelVM execute: nil error: &error];
    
    XCTAssertEqual(error.code, OCSquirrelVMError_FailedToGetCString,
                   @"When a C string could not be retrieved for a script, returned error code "
                   @"should be equal to OCSquirrelVMError_FailedToGetCString");
}


- (void) testExecuteSyncInvalidErrorCodeCompilerError
{
    NSError *error = nil;
    [_squirrelVM execute: @"local x + 0" error: &error];
    
    XCTAssertEqual(error.code, OCSquirrelVMError_CompilerError,
                   @"When compiling script fails, returned error code "
                   @"should be equal to OCSquirrelVMError_CompilerError");
}


- (void) testExecuteSyncInvalidErrorCodeRuntimeError
{
    NSError *error = nil;
    [_squirrelVM execute: @"local x = y;" error: &error];
    
    XCTAssertEqual(error.code, OCSquirrelVMError_RuntimeError,
                   @"When a runtime error occurs, returned error code "
                   @"should be equal to OCSquirrelVMError_RuntimeError");
}


- (void) testExecuteSyncRuntimeErrorCallStack
{
    NSError *error = nil;
    [_squirrelVM execute: @"local x = y;" error: &error];
    
    XCTAssertNotNil(error.userInfo[OCSquirrelVMErrorCallStackUserInfoKey],
                   @"When a runtime error occurs, userInfo dictionary should "
                   @"contain call stack info.");
}


- (void) testExecuteSyncRuntimeErrorCallStackContentClass
{
    NSError *error = nil;
    [_squirrelVM execute: @"function func() { local x = y; } func();" error: &error];
    
    for (id contents in error.userInfo[OCSquirrelVMErrorCallStackUserInfoKey])
    {
        XCTAssertTrue([contents isKindOfClass: [NSDictionary class]],
                     @"Call stack array should contain NSDictionary elements.");
    }
}


- (void) testExecuteSyncRuntimeErrorCallStackContents
{
    NSError *error = nil;
    [_squirrelVM execute: @"function func() { local x = y; } func();" error: &error];
    
    NSArray *callStack = error.userInfo[OCSquirrelVMErrorCallStackUserInfoKey];
    
    XCTAssertTrue([[callStack valueForKey: OCSquirrelVMCallStackFunctionKey] containsObject: @"func"],
                 @"Call stack should contain the function in which the error has occurred.");
}


- (void) testExecuteSyncRuntimeErrorLocals
{
    NSError *error = nil;
    [_squirrelVM execute: @"local x = y;" error: &error];
    
    XCTAssertNotNil(error.userInfo[OCSquirrelVMErrorLocalsUserInfoKey],
                   @"When a runtime error occurs, userInfo dictionary should "
                   @"contain locals info.");
}


- (void) testExecuteSyncRuntimeErrorLocalsContentClass
{
    NSError *error = nil;
    [_squirrelVM execute: @"local x = y;" error: &error];
    
    for (id contents in error.userInfo[OCSquirrelVMErrorLocalsUserInfoKey])
    {
        XCTAssertTrue([contents isKindOfClass: [NSDictionary class]],
                     @"Locals array should contain NSDictionary elements.");
    }
}


- (void) testExecuteSyncRuntimeErrorLocalsContents
{
    NSError *error = nil;
    [_squirrelVM execute: @"local z = \"qwerty\"; local x = y;" error: &error];
    
    NSArray *locals = error.userInfo[OCSquirrelVMErrorLocalsUserInfoKey];
    
    XCTAssertTrue([[locals valueForKey: OCSquirrelVMLocalValueKey] containsObject: @"qwerty"],
                 @"Locals array should contain local variables from the scope of the function "
                 @"where an error has occurred.");
}



- (void) testExecuteSyncInvalidResult
{
    id result = [_squirrelVM execute: @"local x + 0" error: nil];
    
    XCTAssertNil(result,
                @"OCSquirrelVM -executeSync: should return a nil result "
                @"for an invalid Squirrel script.");
}


#pragma mark -
#pragma mark executeSync: result values

- (void) testExecuteSyncResultString
{
    id result = [_squirrelVM execute: @"return \"some string\";" error: nil];
    
    XCTAssertEqualObjects(result, @"some string",
                         @"-executeSync should return the value which the Squirrel script "
                         @"has returned.");
}


- (void) testExecuteSyncResultInteger
{
    id result = [_squirrelVM execute: @"return 12345;" error: nil];
    
    XCTAssertEqualObjects(result, @12345,
                         @"-executeSync should return the value which the Squirrel script "
                         @"has returned.");
}


- (void) testExecuteSyncResultFloat
{
    id result = [_squirrelVM execute: @"return 123.456;" error: nil];
    
    XCTAssertEqualWithAccuracy([result floatValue], 123.456f, 1e-3,
                               @"-executeSync should return the value which the Squirrel script "
                               @"has returned.");
}


- (void) testExecuteSyncResultBool
{
    id result = [_squirrelVM execute: @"return true;" error: nil];
    
    XCTAssertEqualObjects(result, @YES,
                         @"-executeSync should return the value which the Squirrel script "
                         @"has returned.");
}


- (void) testExecuteSyncResultNull
{
    id result = [_squirrelVM execute: @"return null;" error: nil];
    
    XCTAssertNil(result,
                @"-executeSync should return the value which the Squirrel script "
                @"has returned.");
}


- (void) testExecuteSyncResultNone
{
    id result = [_squirrelVM execute: @"local x = 0;" error: nil];
    
    XCTAssertNil(result,
                @"-executeSync should nil if the script does not return anything.");
}

@end
