//
//  OCSquirrelInstanceImpl.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 27.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "OCSquirrelInstanceImpl.h"


#pragma mark -
#pragma mark OCSquirrelInstanceImpl implementation

@implementation OCSquirrelInstanceImpl

#pragma mark -
#pragma mark properties

- (id) instanceUP
{
    __block SQUserPointer userPointer = NULL;
    
    OCSquirrelVM *squirrelVM = self.squirrelVM;
    
    [squirrelVM performPreservingStackTop: ^(HSQUIRRELVM vm, id<OCSquirrelVMStack> stack){
        [self push];
        sq_getinstanceup(vm, -1, &userPointer, 0);
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
