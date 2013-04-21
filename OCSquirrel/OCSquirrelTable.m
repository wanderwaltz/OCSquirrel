//
//  OCSquirrelTable.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 14.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "OCSquirrelTable.h"


#pragma mark -
#pragma mark OCSquirrelTable implementation

@implementation OCSquirrelTable

#pragma mark -
#pragma mark initialization methods

- (id) initWithHSQOBJECT: (HSQOBJECT) object
                    inVM: (OCSquirrelVM *) squirrelVM
{
    if (sq_type(object) == OT_TABLE)
    {
        return [super initWithHSQOBJECT: object
                                   inVM: squirrelVM];
    }
    else return nil;
}

@end
