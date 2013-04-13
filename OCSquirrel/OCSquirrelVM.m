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

static const char * const kOCSquirrelVMCompileBufferSourceName = "buffer";


#pragma mark -
#pragma mark OCSquirrelVM implementation

@implementation OCSquirrelVM

#pragma mark -
#pragma mark properties

- (void) setDelegate: (id<OCSquirrelVMDelegate>) delegate
{
    if (![delegate conformsToProtocol: @protocol(OCSquirrelVMDelegate)])
    {
        [[[NSException alloc] initWithName: NSInvalidArgumentException
                                    reason: @"*** setDelegate: delegate should conform to OCSquirrelVMDelegate protocol"
                                  userInfo: nil] raise];
    }
    
    _delegate = delegate;
}

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


#pragma mark -
#pragma mark script execution

- (id) executeSync: (NSString *) script
{
    __block BOOL success = NO;
    
    dispatch_sync(_vmQueue, ^{
        
        const SQChar *cScript = [script cStringUsingEncoding: NSASCIIStringEncoding];
        
        if (SQ_SUCCEEDED(sq_compilebuffer(_vm, cScript, strlen(cScript),
                                          kOCSquirrelVMCompileBufferSourceName, SQTrue)))
        {
            success = YES;
            sq_call(_vm, 0, NO, SQTrue);
        }
    });
    
    if (!success)
    {
        [[[NSException alloc] initWithName: NSInvalidArgumentException
                                    reason: @"*** executeSync: failed to compile script"
                                  userInfo: nil] raise];
    }
    
    return nil;
}

@end
