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
void OCSquirrelVMPrintfunc(HSQUIRRELVM vm, const SQChar *s, ...);

/// Erro function implementation for OCSquirrelVM
void OCSquirrelVMErrorfunc(HSQUIRRELVM vm, const SQChar *s, ...);