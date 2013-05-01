//
//  OCSquirrelVMBindings.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 4/30/13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCSquirrelVM.h"

SQInteger OCSquirrelVMBindings_Constructor(HSQUIRRELVM vm);

SQInteger OCSquirrelVMBindings_SimpleInvocation(HSQUIRRELVM vm);
SQInteger OCSquirrelVMBindings_InitializerSimpleInvocation(HSQUIRRELVM vm);