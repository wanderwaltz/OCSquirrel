//
//  OCSquirrelArrayImpl.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 6/10/13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "OCSquirrelArrayImpl.h"


#pragma mark -
#pragma mark OCSquirrelArrayImpl implementation

@implementation OCSquirrelArrayImpl

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

- (id) initWithSquirrelVM: (OCSquirrelVM *) squirrelVM
{
    self = [super initWithSquirrelVM: squirrelVM];
    
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
    NSInteger count = self.count;
    
    if ((index >= count) || (count < -index)) {
        @throw [NSException exceptionWithName: NSRangeException
                                       reason: [NSString stringWithFormat:
                                                @"*** objectAtIndex: index %ld is beyound the bounds of the array "
                                                @"with count %lu", (long)index, (unsigned long)self.count]
                                     userInfo: nil];
    }
    
    if (index < 0) {
        index = count+index;
    }
    
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
    NSInteger count = self.count;
    
    if ((index >= count) || (count < -index)) {
        @throw [NSException exceptionWithName: NSRangeException
                                       reason: [NSString stringWithFormat:
                                                @"*** setObject:atIndex: index %ld is beyound the bounds of the array "
                                                @"with count %lu", (long)index, (unsigned long)self.count]
                                     userInfo: nil];
    }
    
    if (index < 0) {
        index = count+index;
    }
    
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


- (void)insertObject:(id)object atIndex:(NSInteger)index
{
    if (index > self.count) {
        @throw [NSException exceptionWithName: NSRangeException
                                       reason: [NSString stringWithFormat:
                                                @"*** insertObject:atIndex: index %ld is beyound the bounds of the array "
                                                @"with count %lu", (long)index, (unsigned long)self.count]
                                     userInfo: nil];
    }
    
    OCSquirrelVM *squirrelVM = self.squirrelVM;
    
    [squirrelVM performPreservingStackTop: ^(HSQUIRRELVM vm, id<OCSquirrelVMStack> stack){
        [self push];
        [stack pushValue: object];
        
        sq_arrayinsert(vm, -2, index);
    }];
}


- (void)removeObjectAtIndex:(NSInteger)index
{
    if (index >= self.count) {
        @throw [NSException exceptionWithName: NSRangeException
                                       reason: [NSString stringWithFormat:
                                                @"*** removeObjectAtIndex: index %ld is beyound the bounds of the array "
                                                @"with count %lu", (long)index, (unsigned long)self.count]
                                     userInfo: nil];
    }
    
    OCSquirrelVM *squirrelVM = self.squirrelVM;
    
    [squirrelVM performPreservingStackTop: ^(HSQUIRRELVM vm, id<OCSquirrelVMStack> stack){
        [self push];
        
        sq_arrayremove(vm, -1, index);
    }];
}


- (id)pop
{
    if (self.count == 0) {
        @throw [NSException exceptionWithName: NSRangeException
                                       reason: @"*** pop *** unable to pop element from an empty array"
                                     userInfo: nil];
    }
    
    __block id result = nil;
    
    OCSquirrelVM *squirrelVM = self.squirrelVM;
    
    [squirrelVM performPreservingStackTop: ^(HSQUIRRELVM vm, id<OCSquirrelVMStack> stack){
        [self push];
        
        sq_arraypop(vm, -1, SQTrue);
        
        result = [stack valueAtPosition: -1];
    }];

    return result;
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
