//
//  OCSquirrelInstance.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 27.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "OCSquirrelInstance.h"


#pragma mark -
#pragma mark OCSquirrelInstance implementation

@implementation OCSquirrelInstance

#pragma mark -
#pragma mark properties

- (id) instanceUP
{
    __block SQUserPointer userPointer = NULL;
    
    OCSquirrelVM *squirrelVM = self.squirrelVM;
    
    [squirrelVM doWaitPreservingStackTop: ^{
        [self push];
        sq_getinstanceup(squirrelVM.vm, -1, &userPointer, 0);
    }];
    
    return (__bridge id)userPointer;
}

#pragma mark -
#pragma mark class methods

+ (BOOL) isAllowedToInitWithSQObjectOfType: (SQObjectType) type
{
    return (type == OT_INSTANCE);
}

@end
