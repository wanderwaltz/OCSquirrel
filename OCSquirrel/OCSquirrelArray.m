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
    
    [squirrelVM performPreservingStackTop: ^(HSQUIRRELVM vm, id<OCSquirrelVMStack> stack){
        [self push];
        result = sq_getsize(vm, -1);
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
        [squirrelVM performPreservingStackTop: ^(HSQUIRRELVM vm, id<OCSquirrelVMStack> stack){
            sq_newarray(vm, 0);
            _obj = [stack sqObjectAtPosition: -1];
            sq_addref(vm, &_obj);
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
    
    [squirrelVM performPreservingStackTop: ^(HSQUIRRELVM vm, id<OCSquirrelVMStack> stack){
        [self push];
        
        [stack pushInteger: index];
        
        if (SQ_SUCCEEDED(sq_get(vm, -2)))
        {
            object = [stack valueAtPosition: -1];
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
    
    [squirrelVM performPreservingStackTop: ^(HSQUIRRELVM vm, id<OCSquirrelVMStack> stack){
        [self push];
        [stack pushValue: object];
        
        sq_arrayappend(vm, -2);
    }];
}


- (void) setObject: (id) object atIndex: (NSInteger) index
{
    OCSquirrelVM *squirrelVM = self.squirrelVM;
    
    [squirrelVM performPreservingStackTop: ^(HSQUIRRELVM vm, id<OCSquirrelVMStack> stack){
        [self push];
        [stack pushInteger: index];
        [stack pushValue: object];
        
        sq_set(vm, -3);
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
        
        [squirrelVM performPreservingStackTop:^(HSQUIRRELVM vm, id<OCSquirrelVMStack> stack){
            
            [self push];
            sq_pushnull(vm);
            
            while(SQ_SUCCEEDED(sq_next(vm, -2)))
            {
                NSInteger index = [stack integerAtPosition: -2];
                id value = [stack valueAtPosition: -1];
                
                sq_pop(vm,2);
                
                BOOL stop = NO;
                
                block(value, index, &stop);
                
                if (stop) break;
            }
        }];
    }
}

@end
