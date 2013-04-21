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

+ (id) rootTableForVM: (OCSquirrelVM *) squirrelVM
{
    __block id table = nil;
    
    [squirrelVM doWait: ^{
        
        SQInteger top = squirrelVM.stack.top;
        
        sq_pushroottable(squirrelVM.vm);
        
        HSQOBJECT root = [squirrelVM.stack sqObjectAtPosition: -1];
        
        table = [[self alloc] initWithHSQOBJECT: root
                                           inVM: squirrelVM];
        
        squirrelVM.stack.top = top;
    }];
    
    
    return table;
}


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

- (SQInteger) integerForKey: (id) key
{
    __block SQInteger value = 0;
    
    OCSquirrelVM *squirrelVM = self.squirrelVM;
    
    [squirrelVM doWait: ^{
        
        NSInteger top = squirrelVM.stack.top;
        [self push];
        
        [squirrelVM.stack pushValue: key];
        
        sq_get(squirrelVM.vm, -2);
        
        value = [squirrelVM.stack integerAtPosition: -1];
        
        self.squirrelVM.stack.top = top;
    }];
    
    return value;
}

@end
