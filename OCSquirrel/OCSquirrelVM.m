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

#import "OCSquirrel.h"
#import "OCSquirrelVM+Protected.h"
#import "OCSquirrelVM+DelegateCallbacks.h"
#import "OCSquirrelVMStackImpl.h"
#import "OCSquirrelVMFunctions.h"



#pragma mark -
#pragma mark Constants

const NSUInteger kOCSquirrelVMDefaultInitialStackSize = 1024;

NSString * const OCSquirrelVMErrorDomain = @"com.frostbit.OCSquirrelVM.error.domain";


/// A source name used when compiling a script from NSString.
static const SQChar * const kOCSquirrelVMCompileBufferSourceName = _SC("buffer");


#pragma mark -
#pragma mark Static constants

/*! An unique constant void* key which will be used by dispatch_queue_set_specific and dispatch_get_specific
 for checking whether the current execution context is within the OCSquirrelVM's serial dispatch queue. This
 is needed to allow synchronous calls which do not result in a deadlock when called on the same queue. 
 */
static const void * const kDispatchSpecificKeyOCSquirrelVMQueue = &kDispatchSpecificKeyOCSquirrelVMQueue;


#pragma mark -
#pragma mark OCSquirrelVM implementation

@implementation OCSquirrelVM

#pragma mark -
#pragma mark properties

- (void) setDelegate: (id<OCSquirrelVMDelegate>) delegate
{
    if (![delegate conformsToProtocol: @protocol(OCSquirrelVMDelegate)])
    {
        @throw [NSException exceptionWithName: NSInvalidArgumentException
                                       reason: @"*** setDelegate: delegate should conform to "
                                               @"OCSquirrelVMDelegate protocol"
                                     userInfo: nil];
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
        dispatch_queue_set_specific(_vmQueue,
                                    kDispatchSpecificKeyOCSquirrelVMQueue,
                                    _vm, NULL);
        
        _stack = [[OCSquirrelVMStackImpl alloc] initWithSquirrelVM: self];
        
        [self doWait: ^{
            sqstd_seterrorhandlers(_vm);
            
            sq_setforeignptr(_vm, (__bridge SQUserPointer)self);
            sq_setprintfunc (_vm, OCSquirrelVMPrintfunc, OCSquirrelVMErrorfunc);
        }];
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

- (id) executeSync: (NSString *) script error: (__autoreleasing NSError **) outError
{
    __block BOOL    success = NO;
    __block NSError *error  = nil;
    __block id      result  = nil;
    
    [self doWait: ^{
        
        const SQChar *cScript = [script cStringUsingEncoding: NSUTF8StringEncoding];
        
        if (cScript != NULL)
        {
            NSInteger top = self.stack.top;
            
            if (SQ_SUCCEEDED(sq_compilebuffer(_vm, cScript, scstrlen(cScript),
                                              kOCSquirrelVMCompileBufferSourceName, SQTrue)))
            {
                sq_pushroottable(_vm);
                if (SQ_SUCCEEDED(sq_call(_vm, 1, SQTrue, SQTrue)))
                {
                    success = YES;
                    result  = [self.stack valueAtPosition: -1];
                }
                else
                {
                    error = [NSError errorWithDomain: OCSquirrelVMErrorDomain
                                                code: OCSquirrelVMError_FailedToCallScript
                                            userInfo: nil];
                }
                
            }
            else
            {
                if (self.lastError != nil)
                {
                    error = self.lastError;
                }
                else
                {
                    error = [NSError errorWithDomain: OCSquirrelVMErrorDomain
                                                code: OCSquirrelVMError_CompilerError
                                            userInfo: nil];
                }
            }
            
            self.stack.top = top;
        }
        else
        {
            error = [NSError errorWithDomain: OCSquirrelVMErrorDomain
                                        code: OCSquirrelVMError_FailedToGetCString
                                    userInfo: nil];
        }
    }];
    
    if (!success)
    {
        if (outError != nil)
        {
            *outError = error;
        }
    }
    
    return result;
}


#pragma mark -
#pragma mark bindings

- (void) bindClass: (Class) aClass
{
    
}


#pragma mark -
#pragma mark GCD-related

- (BOOL) currentlyInVMQueue
{
    return (dispatch_get_specific(kDispatchSpecificKeyOCSquirrelVMQueue) == _vm);
}


- (void) doWait: (dispatch_block_t) block
{
    if (block != nil)
    {
        if (![self currentlyInVMQueue])
            dispatch_sync(_vmQueue, block);
        else
            block();
    }
}

@end
