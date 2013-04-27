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
        [squirrelVM doWaitPreservingStackTop: ^{
            sq_newclosure(squirrelVM.vm, function, 0);
            sq_getstackobj(squirrelVM.vm, -1, &_obj);
            sq_addref(squirrelVM.vm, &_obj);
        }];
    }
    return self;
}


#pragma mark -
#pragma mark methods

- (id) call
{
    return [self callWithEnvironment: [OCSquirrelTable rootTableForVM: self.squirrelVM]];
}


- (id) callWithEnvironment: (OCSquirrelObject *) environment
{
    OCSquirrelVM *squirrelVM = self.squirrelVM;
    
    __block id result = nil;
    
    [squirrelVM doWaitPreservingStackTop: ^{
        [environment push];
        [self push];
        sq_call(squirrelVM.vm, 0, SQTrue, SQTrue);
        result = [squirrelVM.stack valueAtPosition: -1];
    }];
    
    return result;
}

@end
