//
//  OCSquirrelVMFunctions.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 4/26/13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCSquirrelVM.h"

/// Returns the OCSquirrelVM instance associated with a given HSQUIRRELVM
OCSquirrelVM *OCSquirrelVMforVM(HSQUIRRELVM vm);



/// Print function implementation for OCSquirrelVM
void OCSquirrelVMPrintFunc(HSQUIRRELVM vm, const SQChar *s, ...);

/// Error printing function implementation for OCSquirrelVM
void OCSquirrelVMErrorFunc(HSQUIRRELVM vm, const SQChar *s, ...);



/// Runtime error handler
SQInteger OCSquirrelVMRuntimeErrorHandler(HSQUIRRELVM vm);



/// Compiler error handler
void OCSquirrelVMCompilerErrorHandler(HSQUIRRELVM vm,
                                      const SQChar *sError,
                                      const SQChar *sSource,
                                      SQInteger line,
                                      SQInteger column);