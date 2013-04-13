//
//  OCSquirrelVM.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 13.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "OCSquirrelVM.h"

#pragma mark -
#pragma mark Constants

const NSUInteger kOCSquirrelVMDefaultInitialStackSize = 1024;


#pragma mark -
#pragma mark OCSquirrelVM implementation

@implementation OCSquirrelVM

#pragma mark -
#pragma mark initialization methods

- (id) init
{
    return [self initWithStackSize: kOCSquirrelVMDefaultInitialStackSize];
}

- (id) initWithStackSize: (NSUInteger) stackSize
{
    self = [super init];
    
    if (self != nil)
    {
        _vm      = sq_open(stackSize);
        _vmQueue = dispatch_queue_create("OCSquirrelVM dispatch queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}


- (void) dealloc
{
    _vmQueue = nil;
    
    if (_vm != nil)
        sq_close(_vm);
}

@end
