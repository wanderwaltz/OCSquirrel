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

/*! A custom OCSquirrelVM subclass which sets the calledInitWithStackSize property to YES if -initWithStackSize: method has been called with the kOCSquirrelVMDefaultInitialStackSize constant as parameter.
 
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
#pragma mark OCSquirrelPrintDelegate class

/*! A class which is used for testing that delegate method is invoked by OCSquirrelVM when a script tries to print some string. Actual implementation of the delegate method is not important since the method invocation will be tested by an OCMockObject. The OCMockObject cannot mock -respondsToSelector:, so this class is needed only for that. 
 
 See -testPrintCallsDelegateMethod below for more info.
 */
@interface OCSquirrelPrintDelegate : NSObject<OCSquirrelVMDelegate>
@end

@implementation OCSquirrelPrintDelegate

- (void) squirrelVM: (OCSquirrelVM *) squirrelVM didPrintString: (NSString *) string {}

@end


#pragma mark -
#pragma mark TestOCSquirrelVM implementation

@implementation TestOCSquirrelVM

- (void) setUp
{
    [super setUp];
    _squirrelVM          = [[OCSquirrelVM alloc] init];
    _squirrelVM.delegate = self;
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


- (void) testDefaultInitialStackSize
{
    STAssertEquals(_squirrelVM.vm->_stack.capacity(), kOCSquirrelVMDefaultInitialStackSize,
                   @"Initial stack size of a OCSquirrelVM initialized with -init should be equal to kOCSquirrelVMDefaultInitialStackSize");
}


- (void) testCustomInitialStackSize
{
    static const NSUInteger kCustomStackSize = 10;
    
    _squirrelVM = [[OCSquirrelVM alloc] initWithStackSize: kCustomStackSize];
    
    STAssertEquals(_squirrelVM.vm->_stack.capacity(), kCustomStackSize,
                   @"Initial stack size of a OCSquirrelVM initialized with -initWithStackSize: should be equal to kCustomStackSize");
}


- (void) testInitCallsInitWithStackSize
{
    // A custom OCSquirrelVM subclass which sets the calledInitWithStackSize
    // property to YES if -initWithStackSize: method has been called with
    // the kOCSquirrelVMDefaultInitialStackSize constant as parameter.
    OCSquirrelVMInitWithStackSizeOverride *vm = [OCSquirrelVMInitWithStackSizeOverride new];
    
    STAssertTrue(vm.calledInitWithStackSize,
                 @"-init method should have called -initWithStackSize: with kOCSquirrelVMDefaultInitialStackSize param value");
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
                                @"OCSquirrelVM should throw and NSIvalidArgumentException if a delegate not conforming to OCSquirrelVMDelegate protocol is set.");
}


- (void) testDoesNotThrowIfDelegateRightProtocol
{
    id delegate = [OCMockObject mockForProtocol: @protocol(OCSquirrelVMDelegate)];
    
    STAssertNoThrow(_squirrelVM.delegate = delegate,
                    @"OCSquirrelVM does not throw an exception if a delegate conforming to OCSquireelVMDelegate protocol is set.");
}


#pragma mark -
#pragma mark tests for script string execution

- (void) testExecuteSyncValidNoThrow
{
    STAssertNoThrow([_squirrelVM executeSync: @"local x = 0;"],
                    @"OCSquirrelVM -executeSync: should not throw exception for a valid Squirrel script.");
}


- (void) testExecuteSyncInvalidThrows
{
    STAssertThrowsSpecificNamed([_squirrelVM executeSync: @"local x + 0"],
                                NSException, NSInvalidArgumentException,
                   @"OCSquirrelVM -executeSync: should throw an NSInvalidArgumentException for an invalid Squirrel script.");
}


- (void) testPrintCallsDelegateMethod
{
    id delegate = [OCMockObject partialMockForObject: [OCSquirrelPrintDelegate new]];
    
    _squirrelVM.delegate = delegate;

    NSString * const kHelloWorld = @"Hello, World!";
    
    [[delegate expect] squirrelVM: _squirrelVM didPrintString: kHelloWorld];
    
    NSString *printHelloWorld = [NSString stringWithFormat: @"print(\"%@\");", kHelloWorld];
    
    [_squirrelVM executeSync: printHelloWorld];
    
    STAssertNoThrow([delegate verify],
                    @"Delegate method -squirrelVM:didPrintString: should be invoked with the OCSquirrelVM instance which compiled the script and the string which was passed to print function.");
    [NSThread sleepForTimeInterval:1.0];
}


#pragma mark -
#pragma mark OCSquirrelVMDelegate

- (void) squirrelVM: (OCSquirrelVM *) squirrelVM didPrintString: (NSString *) string
{
    
}

@end
