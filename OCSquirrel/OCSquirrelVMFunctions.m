//
//  OCSquirrelVMFunctions.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 4/26/13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "OCSquirrelVMFunctions.h"
#import "OCSquirrelVM+DelegateCallbacks.h"
#import "OCSquirrelVM+Protected.h"


OCSquirrelVM *OCSquirrelVMforVM(HSQUIRRELVM vm)
{
    SQUserPointer squirrelVMCPointer = sq_getforeignptr(vm);
    
    OCSquirrelVM *squirrelVM = (__bridge id)squirrelVMCPointer;
    
    return squirrelVM;
}


void OCSquirrelVMPrintFunc(HSQUIRRELVM vm, const SQChar *s, ...)
{
    OCSquirrelVM *squirrelVM = OCSquirrelVMforVM(vm);
    
    if (squirrelVM != nil)
    {
        SQChar buffer[4096] = {0};
        
        va_list vl;
        va_start(vl, s);
        vsprintf(buffer, s, vl);
        va_end(vl);
        
        [squirrelVM _delegate_didPrintString:
         [[NSString alloc] initWithCString: buffer
                                  encoding: NSUTF8StringEncoding]];
    }
}


void OCSquirrelVMErrorFunc(HSQUIRRELVM vm, const SQChar *s, ...)
{
    OCSquirrelVM *squirrelVM = OCSquirrelVMforVM(vm);
    
    if (squirrelVM != nil)
    {
        SQChar buffer[4096] = {0};
        
        va_list vl;
        va_start(vl, s);
        vsprintf(buffer, s, vl);
        va_end(vl);
        
        [squirrelVM _delegate_didPrintError:
         [[NSString alloc] initWithCString: buffer
                                  encoding: NSUTF8StringEncoding]];
    }
}


static NSString *OCSquirrelVMCallStack(HSQUIRRELVM vm)
{
    return nil;
}


SQInteger OCSquirrelVMRuntimeErrorHandler(HSQUIRRELVM vm)
{
    OCSquirrelVM *squirrelVM = OCSquirrelVMforVM(vm);
    
    if (squirrelVM != nil)
    {
        const SQChar *sErrorMessage = 0;
        
		if (sq_gettop(vm) >= 1)
        {
			sq_getstring(vm, 2, &sErrorMessage);
        }
        
        
        NSString *errorMessage = nil;
        
        if (sErrorMessage != NULL)
        {
            errorMessage = [[NSString alloc] initWithCString: sErrorMessage
                                                    encoding: NSUTF8StringEncoding];
        }
        else
        {
            errorMessage = @"An unknown error occurred.";
        }
        
        NSError *error = [NSError errorWithDomain: OCSquirrelVMErrorDomain
                                             code: OCSquirrelVMError_RuntimeError
                                         userInfo: @{ NSLocalizedDescriptionKey : errorMessage }];
        
        squirrelVM.lastError = error;
    }
    
    return 0;
}


void OCSquirrelVMCompilerErrorHandler(HSQUIRRELVM vm,
                                      const SQChar *sError,
                                      const SQChar *sSource,
                                      SQInteger line,
                                      SQInteger column)
{
    OCSquirrelVM *squirrelVM = OCSquirrelVMforVM(vm);
    
    if (squirrelVM != nil)
    {
        NSString *errorMessage =
        [NSString stringWithFormat: @"%s line = (%d) column = (%d) : error %s",
         sSource, line, column, sError];
        
        NSError *error = [NSError errorWithDomain: OCSquirrelVMErrorDomain
                                             code: OCSquirrelVMError_CompilerError
                                         userInfo: @{ NSLocalizedDescriptionKey : errorMessage }];
        
        squirrelVM.lastError = error;
    }
}