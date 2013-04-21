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


#pragma mark -
#pragma mark methods

- (SQInteger) integerForKey: (NSString *) key
{
    __block SQInteger value = 0;
    
    OCSquirrelVM *squirrelVM = self.squirrelVM;
    
    [squirrelVM doWait: ^{
        
        NSInteger top = squirrelVM.stack.top;
        [self push];
        
        const SQChar *cKey = [key cStringUsingEncoding: NSUTF8StringEncoding];
        
        sq_pushstring(squirrelVM.vm, cKey, scstrlen(cKey));
        sq_get(squirrelVM.vm, -2);
        sq_getinteger(squirrelVM.vm, -1, &value);
        
        self.squirrelVM.stack.top = top;
    }];
    
    return value;
}

@end
