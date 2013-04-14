//
//  OCSquirrel.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 13.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#ifndef OCSquirrel_OCSquirrel_h
#define OCSquirrel_OCSquirrel_h

#import <Foundation/Foundation.h>


// Import original Squirrel API
#import "squirrel.h"

#import "sqstdaux.h"
#import "sqstdblob.h"
#import "sqstdio.h"
#import "sqstdmath.h"
#import "sqstdstring.h"
#import "sqstdsystem.h"


// Forward declarations for OCSquirrel classes
// (needed so all other .h files could just #import "OCSquirrel.h"
// and no dependency problems to arise)
@class OCSquirrelVM;
@class OCSquirrelObject;

@protocol OCSquirrelVMDelegate;
@protocol OCSquirrelVMStack;


// Import classes provided by the OCSquirrel
#import "OCSQuirrelVMStack.h"
#import "OCSquirrelVM.h"
#import "OCSquirrelObject.h"

#endif
