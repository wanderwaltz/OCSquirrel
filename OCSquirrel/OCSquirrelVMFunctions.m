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


static NSArray * OCSquirrelVMCallStackInfo(HSQUIRRELVM vm)
{
    NSMutableArray *result = [NSMutableArray array];
    
    SQStackInfos stackInfos;
    SQInteger    level = 1; // 1 is to skip the current function that is level 0

    while (SQ_SUCCEEDED(sq_stackinfos(vm, level, &stackInfos)))
    {
        const SQChar *function = _SC("unknown");
        const SQChar *source   = _SC("unknown");
        
        if (stackInfos.funcname) function = stackInfos.funcname;
        if (stackInfos.source)   source   = stackInfos.source;
        
        [result addObject:
         @{
            OCSquirrelVMCallStackLineKey     : @(stackInfos.line),
            OCSquirrelVMCallStackSourceKey   : [NSString stringWithFormat: @"%s", source],
            OCSquirrelVMCallStackFunctionKey : [NSString stringWithFormat: @"%s", function]
         }];
        
        level++;
    }
    
    return [result copy];
}


static NSArray * OCSquirrelVMLocalsInfo(HSQUIRRELVM vm)
{
    OCSquirrelVM *squirrelVM = OCSquirrelVMforVM(vm);
    NSMutableArray   *result = [NSMutableArray array];
    
    SQInteger level = 0;
    const SQChar *name = 0;
    SQInteger seq = 0;
    
    for (level = 0; level < 10; level++)
    {
        seq = 0;
        
        while ((name = sq_getlocal(vm, level, seq)))
        {
            seq++;
            
            id value = [squirrelVM.stack valueAtPosition: -1];
            
            NSMutableDictionary *localInfo = [NSMutableDictionary dictionaryWithCapacity: 2];
            
            localInfo[OCSquirrelVMLocalNameKey] = [NSString stringWithFormat: @"%s", name];
            
            if (value != nil)
                localInfo[OCSquirrelVMLocalValueKey] = value;
            else
                localInfo[OCSquirrelVMLocalValueKey] = [NSNull null];
            
            [result addObject: [localInfo copy]];
        
            sq_pop(vm,1);
        }
    }
    
    return [result copy];
}


SQInteger OCSquirrelVMRuntimeErrorHandler(HSQUIRRELVM vm)
{
    OCSquirrelVM *squirrelVM = OCSquirrelVMforVM(vm);
    
    [squirrelVM doWait:
     ^{
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
        
         NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        
         // Add error message if possible
         if (errorMessage != nil)
            userInfo[NSLocalizedDescriptionKey] = errorMessage;
        
         
         // Add call stack info if possible
         NSArray *callStack = OCSquirrelVMCallStackInfo(vm);
         if (callStack != nil)
            userInfo[OCSquirrelVMErrorCallStackUserInfoKey] = callStack;
         
         
         // Add info about locals if possible
         NSArray *locals = OCSquirrelVMLocalsInfo(vm);
         if (locals != nil)
             userInfo[OCSquirrelVMErrorLocalsUserInfoKey] = locals;
        
         
         NSError *error = [NSError errorWithDomain: OCSquirrelVMErrorDomain
                                              code: OCSquirrelVMError_RuntimeError
                                          userInfo: [userInfo copy]];
        
         squirrelVM.lastError = error;
     }];
    
    return 0;
}


void OCSquirrelVMCompilerErrorHandler(HSQUIRRELVM vm,
                                      const SQChar *sError,
                                      const SQChar *sSource,
                                      SQInteger line,
                                      SQInteger column)
{
    OCSquirrelVM *squirrelVM = OCSquirrelVMforVM(vm);
    
    [squirrelVM doWait:
    ^{
        NSString *errorMessage =
        [NSString stringWithFormat: @"[%s] line = (%d), column = (%d) : error %s",
         sSource, line, column, sError];
        
        NSError *error = [NSError errorWithDomain: OCSquirrelVMErrorDomain
                                             code: OCSquirrelVMError_CompilerError
                                         userInfo: @{ NSLocalizedDescriptionKey : errorMessage }];
        
        squirrelVM.lastError = error;
    }];
}