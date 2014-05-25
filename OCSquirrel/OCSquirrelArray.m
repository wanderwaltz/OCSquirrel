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
    
    [squirrelVM performPreservingStackTop: ^{
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
        [squirrelVM performPreservingStackTop: ^{
            sq_newarray(squirrelVM.vm, 0);
            _obj = [squirrelVM.stack sqObjectAtPosition: -1];
            sq_addref(squirrelVM.vm, &_obj);
        }];
    }
    return self;
}



#pragma mark -
#pragma mark methods

- (id) objectAtIndex: (NSInteger) index
{
    __block id object = nil;
    
    OCSquirrelVM *squirrelVM = self.squirrelVM;
    
    [squirrelVM performPreservingStackTop: ^{
        [self push];
        
        [squirrelVM.stack pushInteger: index];
        
        if (SQ_SUCCEEDED(sq_get(squirrelVM.vm, -2)))
        {
            object = [squirrelVM.stack valueAtPosition: -1];
        }
    }];
    
    return object;
}


- (id) objectAtIndexedSubscript: (NSInteger) index
{
    return [self objectAtIndex: index];
}


- (void) addObject: (id) object
{
    OCSquirrelVM *squirrelVM = self.squirrelVM;
    
    [squirrelVM performPreservingStackTop: ^{
        [self push];
        [squirrelVM.stack pushValue: object];
        
        sq_arrayappend(squirrelVM.vm, -2);
    }];
}


- (void) setObject: (id) object atIndex: (NSInteger) index
{
    OCSquirrelVM *squirrelVM = self.squirrelVM;
    
    [squirrelVM performPreservingStackTop: ^{
        [self push];
        [squirrelVM.stack pushInteger: index];
        [squirrelVM.stack pushValue: object];
        
        sq_set(squirrelVM.vm, -3);
    }];
}


- (void) setObject: (id) object atIndexedSubscript: (NSInteger) index
{
    [self setObject: object atIndex: index];
}


- (void) enumerateObjectsUsingBlock: (void (^)(id object, NSInteger index, BOOL *stop)) block
{
    if (block != nil)
    {
        OCSquirrelVM *squirrelVM = self.squirrelVM;
        
        [squirrelVM performPreservingStackTop:^{
            
            [self push];
            sq_pushnull(squirrelVM.vm);
            
            while(SQ_SUCCEEDED(sq_next(squirrelVM.vm, -2)))
            {
                NSInteger index = [squirrelVM.stack integerAtPosition: -2];
                id value = [squirrelVM.stack valueAtPosition: -1];
                
                sq_pop(squirrelVM.vm,2);
                
                BOOL stop = NO;
                
                block(value, index, &stop);
                
                if (stop) break;
            }
        }];
    }
}

@end
