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


OCSquirrelVM *OCSquirrelVMforVM(HSQUIRRELVM vm)
{
    SQUserPointer squirrelVMCPointer = sq_getforeignptr(vm);
    
    OCSquirrelVM *squirrelVM = (__bridge id)squirrelVMCPointer;
    
    return squirrelVM;
}


void OCSquirrelVMPrintfunc(HSQUIRRELVM vm, const SQChar *s, ...)
{
    SQChar buffer[4096] = {0};
    
	va_list vl;
	va_start(vl, s);
	vsprintf(buffer, s, vl);
	va_end(vl);
    
    OCSquirrelVM *squirrelVM = OCSquirrelVMforVM(vm);
    
    [squirrelVM _delegate_didPrintString:
     [[NSString alloc] initWithCString: buffer
                              encoding: NSUTF8StringEncoding]];
}


void OCSquirrelVMErrorfunc(HSQUIRRELVM vm, const SQChar *s, ...)
{
    // TODO: implement
}