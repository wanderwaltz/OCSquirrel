//
//  OCSquirrelClass.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 27.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "OCSquirrelClass.h"


#pragma mark -
#pragma mark OCSquirrelClass implementation

@implementation OCSquirrelClass

#pragma mark -
#pragma mark initialization methods

- (id) initWithVM: (OCSquirrelVM *) squirrelVM
{
    self = [super initWithVM: squirrelVM];
    
    if (self != nil)
    {
        [squirrelVM doWaitPreservingStackTop: ^{
            sq_newclass(squirrelVM.vm, SQFalse);
            sq_getstackobj(squirrelVM.vm, -1, &_obj);
            sq_addref(squirrelVM.vm, &_obj);
        }];
    }
    return self;
}

@end
