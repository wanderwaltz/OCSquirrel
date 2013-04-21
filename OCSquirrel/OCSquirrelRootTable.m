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
    self = [super initWithVM: squirrelVM];
    
    if (self != nil)
    {
        
    }
    return self;
}


- (void) dealloc
{
    
}

@end
