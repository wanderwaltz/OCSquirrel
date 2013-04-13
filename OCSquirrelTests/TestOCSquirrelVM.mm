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


- (void) testSquirrelVMCreation
{
    STAssertNotNil(_squirrelVM,
                   @"OCSquirrelVM class should be created");
}


- (void) testSquirrelVMHasVMProperty
{
    STAssertTrue(_squirrelVM.vm != NULL,
                 @"OCSquirrelVM should have a non-nil vm property.");
}


- (void) testSquirrelVMDefaultInitialStackSize
{
    STAssertEquals(_squirrelVM.vm->_stack.capacity(), kOCSquirrelVMDefaultInitialStackSize,
                   @"Initial stack size of a OCSquirrelVM initialized with -init should be equal to kOCSquirrelVMDefaultInitialStackSize");
}


- (void) testSquirrelVMCustomInitialStackSize
{
    static const NSUInteger kCustomStackSize = 10;
    
    _squirrelVM = [[OCSquirrelVM alloc] initWithStackSize: kCustomStackSize];
    
    STAssertEquals(_squirrelVM.vm->_stack.capacity(), kCustomStackSize,
                   @"Initial stack size of a OCSquirrelVM initialized with -initWithStackSize: should be equal to kCustomStackSize");
}


- (void) testSquirrelVMHasDispatchQueue
{
    STAssertNotNil(_squirrelVM.vmQueue,
                   @"OCSquirrelVM should have a dispatch queue to serialize calls to the vm");
}

@end
