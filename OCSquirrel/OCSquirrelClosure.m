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
    return (type == OT_CLOSURE) || (type == OT_NATIVECLOSURE);
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
    return [self callWithThis: [OCSquirrelTable rootTableForVM: self.squirrelVM]
                   parameters: nil];
}


- (id) call: (NSArray *) parameters
{
    return [self callWithThis: [OCSquirrelTable rootTableForVM: self.squirrelVM]
                   parameters: parameters];
}


- (id) callWithThis: (OCSquirrelObject *) this
{
    return [self callWithThis: this
                   parameters: nil];
}


- (id) callWithThis: (OCSquirrelObject *) this
         parameters: (NSArray *) parameters
{
    OCSquirrelVM *squirrelVM = self.squirrelVM;
    
    __block id result = nil;
    
    [squirrelVM doWaitPreservingStackTop: ^{
        [self push]; // Pushes the closure to the stack
        [this push]; // Pushes the 'this' object to the stack
        
        for (id parameter in parameters)
        {
            [squirrelVM.stack pushValue: parameter];
        }
        
        // Parameters count is at least 1 since the first parameter is
        // always the 'this' object.
        sq_call(squirrelVM.vm, parameters.count+1, SQTrue, SQTrue);
        result = [squirrelVM.stack valueAtPosition: -1];
    }];
    
    return result;
}

@end
