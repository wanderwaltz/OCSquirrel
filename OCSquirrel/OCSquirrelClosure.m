//
//  OCSquirrelClosure.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 27.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "OCSquirrelClosure.h"


#pragma mark -
#pragma mark OCSquirrelClosure implementation

@implementation OCSquirrelClosure

#pragma mark -
#pragma mark class methods

+ (BOOL) isAllowedToInitWithSQObjectOfType: (SQObjectType) type
{
    return (type == OT_CLOSURE);
}


#pragma mark -
#pragma mark initialization methods

- (id) initWithSQFUNCTION: (SQFUNCTION) function
               squirrelVM: (OCSquirrelVM *) squirrelVM
{
    self = [super initWithVM: squirrelVM];
    
    if (self != nil)
    {
        
    }
    return self;
}

@end
