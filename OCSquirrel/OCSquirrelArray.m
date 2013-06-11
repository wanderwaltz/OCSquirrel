//
//  OCSquirrelArray.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 6/10/13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "OCSquirrelArray.h"


#pragma mark -
#pragma mark OCSquirrelArray implementation

@implementation OCSquirrelArray

#pragma mark -
#pragma mark properties

- (NSUInteger) count
{
    __block NSUInteger result = 0;
    
    OCSquirrelVM *squirrelVM = self.squirrelVM;
    
    [squirrelVM doWaitPreservingStackTop: ^{
        [self push];
        result = sq_getsize(squirrelVM.vm, -1);
    }];
    
    return result;
}


#pragma mark -
#pragma mark class methods

+ (BOOL) isAllowedToInitWithSQObjectOfType: (SQObjectType) type
{
    return (type == OT_ARRAY);
}


#pragma mark -
#pragma mark initialization methods

- (id) initWithVM: (OCSquirrelVM *) squirrelVM
{
    self = [super initWithVM: squirrelVM];
    
    if (self != nil)
    {
        [squirrelVM doWaitPreservingStackTop: ^{
            sq_newarray(squirrelVM.vm, 0);
            _obj = [squirrelVM.stack sqObjectAtPosition: -1];
            sq_addref(squirrelVM.vm, &_obj);
        }];
    }
    return self;
}



#pragma mark -
#pragma mark methods

- (void) addObject: (id) object
{
    OCSquirrelVM *squirrelVM = self.squirrelVM;
    
    [squirrelVM doWaitPreservingStackTop: ^{
        [self push];
        [squirrelVM.stack pushValue: object];
        
        sq_arrayappend(squirrelVM.vm, -2);
    }];
}


@end
