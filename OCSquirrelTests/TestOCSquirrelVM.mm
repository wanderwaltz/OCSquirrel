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

#import "TestOCSquirrelVM.h"
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
    STAssertNotNil(_squirrelVM,
                   @"OCSquirrelVM class should be created");
}


- (void) testHasVMProperty
{
    STAssertTrue(_squirrelVM.vm != NULL,
                 @"OCSquirrelVM should have a non-nil vm property.");
}


- (void) testForeignPtr
{
    SQUserPointer vmPointer = sq_getforeignptr(_squirrelVM.vm);

    STAssertEquals(vmPointer, (__bridge SQUserPointer)_squirrelVM,
                   @"OCSquirrelVM should set self as the foreign ptr for the Squirrel VM");
}


- (void) testDefaultInitialStackSize
{
    STAssertEquals(_squirrelVM.vm->_stack.capacity(), kOCSquirrelVMDefaultInitialStackSize,
                   @"Initial stack size of a OCSquirrelVM initialized with -init should be equal to "
                   @"kOCSquirrelVMDefaultInitialStackSize");
}


- (void) testCustomInitialStackSize
{
    static const NSUInteger kCustomStackSize = 10;
    
    _squirrelVM = [[OCSquirrelVM alloc] initWithStackSize: kCustomStackSize];
    
    STAssertEquals(_squirrelVM.vm->_stack.capacity(), kCustomStackSize,
                   @"Initial stack size of a OCSquirrelVM initialized with -initWithStackSize: "
                   @"should be equal to kCustomStackSize");
}


- (void) testInitCallsInitWithStackSize
{
    // A custom OCSquirrelVM subclass which sets the calledInitWithStackSize
    // property to YES if -initWithStackSize: method has been called with
    // the kOCSquirrelVMDefaultInitialStackSize constant as parameter.
    OCSquirrelVMInitWithStackSizeOverride *vm = [OCSquirrelVMInitWithStackSizeOverride new];
    
    STAssertTrue(vm.calledInitWithStackSize,
                 @"-init method should have called -initWithStackSize: with "
                 @"kOCSquirrelVMDefaultInitialStackSize param value");
}


- (void) testHasDispatchQueue
{
    STAssertNotNil(_squirrelVM.vmQueue,
                   @"OCSquirrelVM should have a dispatch queue to serialize calls to the vm");
}


- (void) testHasDelegateProperty
{
    STAssertTrue([OCSquirrelVM instancesRespondToSelector: @selector(setDelegate:)] &&
                 [OCSquirrelVM instancesRespondToSelector: @selector(delegate)],
                 @"OCSquirrelVM should have a readwrite delegate property");
}


- (void) testThrowsIfDelegateWrongProtocol
{
    STAssertThrowsSpecificNamed(_squirrelVM.delegate = (id)[NSObject new],
                                NSException, NSInvalidArgumentException,
                                @"OCSquirrelVM should throw and NSIvalidArgumentException if a delegate "
                                @"not conforming to OCSquirrelVMDelegate protocol is set.");
}


- (void) testDoesNotThrowIfDelegateRightProtocol
{
    id delegate = [OCMockObject mockForProtocol: @protocol(OCSquirrelVMDelegate)];
    
    STAssertNoThrow(_squirrelVM.delegate = delegate,
                    @"OCSquirrelVM does not throw an exception if a delegate conforming to "
                    @"OCSquireelVMDelegate protocol is set.");
}


#pragma mark -
#pragma mark executeSync: errors

- (void) testExecuteSyncValidNoThrow
{
    STAssertNoThrow([_squirrelVM executeSync: @"local x = 0;" error: nil],
                    @"OCSquirrelVM -executeSync: should not throw exception for a valid Squirrel script.");
}


- (void) testExecuteSyncInvalidError
{
    NSError *error = nil;
    [_squirrelVM executeSync: @"local x + 0" error: &error];
    
    STAssertNotNil(error,
                   @"OCSquirrelVM -executeSync: should return a not nil NSError "
                   @"for an invalid Squirrel script.");
}


- (void) testExecuteSyncInvalidLastError
{
    NSError *error = nil;
    [_squirrelVM executeSync: @"local x + 0" error: &error];
    
    STAssertEqualObjects(error, _squirrelVM.lastError,
                         @"OCSquirrelVM -executeSync: should return a not nil NSError "
                         @"and have a lastError property with the same error.");
}


- (void) testExecuteSyncInvalidErrorDomain
{
    NSError *error = nil;
    [_squirrelVM executeSync: @"local x + 0" error: &error];
    
    STAssertEqualObjects(error.domain, OCSquirrelVMErrorDomain,
                         @"Error returned by OCSquirrelVM should have OCSquirrelVMErrorDomain domain.");
}


- (void) testExecuteSyncInvalidErrorCodeFailedGetCString
{
    NSError *error = nil;
    [_squirrelVM executeSync: nil error: &error];
    
    STAssertEquals(error.code, OCSquirrelVMError_FailedToGetCString,
                   @"When a C string could not be retrieved for a script, returned error code "
                   @"should be equal to OCSquirrelVMError_FailedToGetCString");
}


- (void) testExecuteSyncInvalidErrorCodeCompilerError
{
    NSError *error = nil;
    [_squirrelVM executeSync: @"local x + 0" error: &error];
    
    STAssertEquals(error.code, OCSquirrelVMError_CompilerError,
                   @"When compiling script fails, returned error code "
                   @"should be equal to OCSquirrelVMError_CompilerError");
}


- (void) testExecuteSyncInvalidErrorCodeRuntimeError
{
    NSError *error = nil;
    [_squirrelVM executeSync: @"local x = y;" error: &error];
    
    STAssertEquals(error.code, OCSquirrelVMError_RuntimeError,
                   @"When a runtime error occurs, returned error code "
                   @"should be equal to OCSquirrelVMError_RuntimeError");
}



- (void) testExecuteSyncInvalidResult
{
    id result = [_squirrelVM executeSync: @"local x + 0" error: nil];
    
    STAssertNil(result,
                @"OCSquirrelVM -executeSync: should return a nil result "
                @"for an invalid Squirrel script.");
}


#pragma mark executeSync: result values

- (void) testExecuteSyncResultString
{
    id result = [_squirrelVM executeSync: @"return \"some string\";" error: nil];
    
    STAssertEqualObjects(result, @"some string",
                         @"-executeSync should return the value which the Squirrel script "
                         @"has returned.");
}


- (void) testExecuteSyncResultInteger
{
    id result = [_squirrelVM executeSync: @"return 12345;" error: nil];
    
    STAssertEqualObjects(result, @12345,
                         @"-executeSync should return the value which the Squirrel script "
                         @"has returned.");
}


- (void) testExecuteSyncResultFloat
{
    id result = [_squirrelVM executeSync: @"return 123.456;" error: nil];
    
    STAssertEqualsWithAccuracy([result floatValue], 123.456f, 1e-3,
                               @"-executeSync should return the value which the Squirrel script "
                               @"has returned.");
}


- (void) testExecuteSyncResultBool
{
    id result = [_squirrelVM executeSync: @"return true;" error: nil];
    
    STAssertEqualObjects(result, @YES,
                         @"-executeSync should return the value which the Squirrel script "
                         @"has returned.");
}


- (void) testExecuteSyncResultNull
{
    id result = [_squirrelVM executeSync: @"return null;" error: nil];
    
    STAssertNil(result,
                @"-executeSync should return the value which the Squirrel script "
                @"has returned.");
}


- (void) testExecuteSyncResultNone
{
    id result = [_squirrelVM executeSync: @"local x = 0;" error: nil];
    
    STAssertNil(result,
                @"-executeSync should nil if the script does not return anything.");
}

@end
