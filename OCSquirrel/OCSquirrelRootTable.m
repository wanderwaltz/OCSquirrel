//
//  OCSquirrelRootTable.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 14.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "OCSquirrelRootTable.h"


#pragma mark -
#pragma mark OCSquirrelRootTable implementation

@implementation OCSquirrelRootTable

#pragma mark -
#pragma mark initialization methods

- (id) initWithVM: (OCSquirrelVM *) squirrelVM
{
    __block HSQOBJECT root;
    
    [squirrelVM doWait:^{
        NSUInteger top = squirrelVM.stack.top;
        
        sq_pushroottable(squirrelVM.vm);
        sq_getstackobj(squirrelVM.vm, -1, &root);
    
        squirrelVM.stack.top = top;
    }];
    
    self = [super initWithVM: squirrelVM];
    
    if (self != nil)
    {
        _obj = root;
        [squirrelVM doWait:^{
            sq_addref(_squirrelVM.vm, &_obj);
        }];
    }
    return self;
}


- (id) initWithHSQOBJECT: (HSQOBJECT) object
                    inVM: (OCSquirrelVM *) squirrelVM
{
    @throw [NSException exceptionWithName: NSGenericException
                                   reason: @"*** OCSquirrelRootTable should not be initialized with "
                                           @"initWithHSQOBJECT:inVM: method; use initWithVM: instead."
                                 userInfo: nil];
    
    return nil;
}

@end
