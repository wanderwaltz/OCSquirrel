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
#import "OCSquirrelVMBindings_NoARC.h"

#import "OCSquirrelClass.h"
#import "OCSquirrelTable.h"
#import "OCSquirrelClosure.h"



#pragma mark -
#pragma mark Constants

const NSUInteger kOCSquirrelVMDefaultInitialStackSize = 1024;

NSString * const OCSquirrelVMErrorDomain = @"com.frostbit.OCSquirrelVM.error.domain";

NSString * const OCSquirrelVMErrorCallStackUserInfoKey =
    @"com.frostbit.OCSquirrelVM.error.userInfo.callStack";

NSString * const OCSquirrelVMErrorLocalsUserInfoKey =
    @"com.frostbit.OCSquirrelVM.error.userInfo.locals";


NSString * const OCSquirrelVMCallStackFunctionKey = @"function";
NSString * const OCSquirrelVMCallStackLineKey     = @"line";
NSString * const OCSquirrelVMCallStackSourceKey   = @"source";


NSString * const OCSquirrelVMLocalNameKey  = @"name";
NSString * const OCSquirrelVMLocalValueKey = @"value";



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


- (NSDictionary *) classBindings
{
    return _classBindings;
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
        _classBindings = [NSMutableDictionary dictionary];
        
        [self doWait: ^{
            
            // Adding custom implementations of compiler and runtime error
            // handlers since we need something a bit different than the
            // sqstdaux implementations can provide.
            sq_setcompilererrorhandler(_vm, OCSquirrelVMCompilerErrorHandler);
            sq_newclosure(_vm, OCSquirrelVMRuntimeErrorHandler, 0);
            sq_seterrorhandler(_vm);
            
            // Print and error functions
            sq_setforeignptr(_vm, (__bridge SQUserPointer)self);
            sq_setprintfunc (_vm, OCSquirrelVMPrintFunc, OCSquirrelVMErrorFunc);
        }];
    }
    return self;
}


- (void) dealloc
{
    _classBindings = nil;
    _vmQueue       = nil;
    
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
                    if (self.lastError != nil)
                    {
                        error = self.lastError;
                    }
                    else
                    {
                        error = [NSError errorWithDomain: OCSquirrelVMErrorDomain
                                                    code: OCSquirrelVMError_RuntimeError
                                                userInfo: nil];
                    }
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

- (OCSquirrelClass *) bindClass: (Class) aClass;
{
    __block OCSquirrelClass *class = nil;
    
    [self doWaitPreservingStackTop:^{
        NSString *className = NSStringFromClass(aClass);
        
        class = _classBindings[className];
        
        if (class == nil)
        {
            class = [[OCSquirrelClass alloc] initWithVM: self];
            _classBindings[className] = class;
            
            // Set the top level class attributes to the Objective-C class
            // pointer for easy access if needed. This is used by the
            // OCSquirrelVMStackImpl for example to determine whether some
            // particular Squirrel class is actually a bound native class
            // or not and return the corresponding OCSquirrelClass instance
            [class setClassAttributes: [NSValue valueWithPointer: (__bridge void *)aClass]];
            
            // Bind constructor. Note that the constructor only does alloc
            // an instance of the native class without initializing it,
            // so further calls to -init or other initializers should be
            // then immediately performed using one of the bound initializer
            // methods.
            id constructor =
            [[OCSquirrelClosure alloc] initWithSQFUNCTION: OCSquirrelVMBindings_Constructor
                                               squirrelVM: self];
            [class setObject: constructor forKey: @"constructor"];

            
            id init =
            [[OCSquirrelClosure alloc] initWithSQFUNCTION:
             OCSquirrelVMBindings_InitializerSimpleInvocation
                                                     name: @"init"
                                               squirrelVM: self];
            [class setObject: init forKey: @"init"];

            
        }
    }];
    
    return class;
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


- (void) doWaitPreservingStackTop: (dispatch_block_t) block
{
    [self doWait: ^{
        NSInteger top = self.stack.top;
        
        [self doWait: block];
        
        self.stack.top = top;
    }];
}

@end
