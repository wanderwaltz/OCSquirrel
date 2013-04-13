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
#import "OCSquirrelVM+DelegateCallbacks.h"

#pragma mark -
#pragma mark Constants

const NSUInteger kOCSquirrelVMDefaultInitialStackSize = 1024;

static const SQChar * const kOCSquirrelVMCompileBufferSourceName = "buffer";
static const SQChar * const kRootTableKeyUPSquirrelVM = "___UPsquirrelVM";


#pragma mark -
#pragma mark Squirrel bindings

void OCSquirrelVMPrintfunc(HSQUIRRELVM vm, const SQChar *s, ...)
{
    char buffer[4096] = {0};
    
	va_list vl;
	va_start(vl, s);
	vsprintf(buffer, s, vl);
	va_end(vl);
    
    void *squirrelVMCPointer = nil;
    
    SQInteger top = sq_gettop(vm);
    sq_pushroottable(vm);
    sq_pushstring(vm, kRootTableKeyUPSquirrelVM, strlen(kRootTableKeyUPSquirrelVM));
    sq_rawget(vm, -2);
    sq_getuserpointer(vm, -1, &squirrelVMCPointer);
    sq_settop(vm, top);
    
    OCSquirrelVM *squirrelVM = (__bridge id)squirrelVMCPointer;
    [squirrelVM _delegate_didPrintString:
     [[NSString alloc] initWithCString: buffer
                              encoding: NSASCIIStringEncoding]];
}


void OCSquirrelVMErrorfunc(HSQUIRRELVM vm, const SQChar *s, ...)
{
    // TODO: implement
}


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
                                       reason: @"*** setDelegate: delegate should conform to \
                                                OCSquirrelVMDelegate protocol"
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
        
        dispatch_sync(_vmQueue, ^{
            sqstd_seterrorhandlers(_vm);
            
            SQInteger top = sq_gettop(_vm);
            sq_pushroottable(_vm);
            sq_pushstring(_vm, kRootTableKeyUPSquirrelVM, strlen(kRootTableKeyUPSquirrelVM));
            sq_pushuserpointer(_vm, (__bridge void *)self);
            
            if (SQ_FAILED(sq_newslot(_vm, -3, SQFalse)))
            {
                @throw [NSException exceptionWithName: NSInternalInconsistencyException
                                               reason: @"*** initWithStackSize: failed to store the \
                                                        OCSquirrelVM user pointer in the Squirrel VM \
                                                        root table."
                                             userInfo: nil];
            }
            
            sq_settop(_vm, top);
            
            sq_setprintfunc(_vm, OCSquirrelVMPrintfunc, OCSquirrelVMErrorfunc);
        });
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
    __block BOOL      success         = NO;
    __block NSString *exceptionReason = nil;
    
    dispatch_sync(_vmQueue, ^{
        
        const SQChar *cScript = [script cStringUsingEncoding: NSASCIIStringEncoding];
        
        SQInteger top = sq_gettop(_vm);
        
        if (SQ_SUCCEEDED(sq_compilebuffer(_vm, cScript, strlen(cScript),
                                          kOCSquirrelVMCompileBufferSourceName, SQTrue)))
        {
            sq_pushroottable(_vm);
            if (SQ_SUCCEEDED(sq_call(_vm, 1, SQFalse, SQTrue)))
            {
                success = YES;
            }
            else
            {
                exceptionReason = @"*** executeSync: failed to call compiled script function";
            }

        }
        else
        {
            exceptionReason = @"*** executeSync: failed to compile script";
        }
        
        sq_settop(_vm, top);
    });
    
    if (!success)
    {
        @throw [NSException exceptionWithName: NSInvalidArgumentException
                                       reason: exceptionReason
                                     userInfo: nil];
    }
    
    return nil;
}

@end
