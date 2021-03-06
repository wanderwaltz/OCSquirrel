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


// Import classes provided by OCSquirrel
#import "OCSQuirrelVMStack.h"
#import "OCSquirrelVM.h"
#import "OCSquirrelVM+SQObjects.h"

#import "OCSquirrelObject.h"
#import "OCSquirrelTable.h"
#import "OCSquirrelArray.h"

#import "OCSquirrelUserData.h"
#import "OCSquirrelClosure.h"

#import "OCSquirrelClass.h"
#import "OCSquirrelInstance.h"


#endif
