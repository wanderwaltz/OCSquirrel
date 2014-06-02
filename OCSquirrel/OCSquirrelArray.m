//
//  OCSquirrelArray.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 26.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "OCSquirrelArray.h"
#import "OCSquirrelArray+Protected.h"
#import "OCSquirrelArrayImpl.h"

@implementation OCSquirrelArray

#pragma mark - protected

- (instancetype)initWithImpl:(OCSquirrelArrayImpl *)impl
{
    self = [super init];
    
    if (self != nil) {
        _impl = impl;
    }
    
    return self;
}

#pragma mark - initialization methods

- (instancetype)init
{
    OCSquirrelArrayImpl *impl = [[OCSquirrelArrayImpl alloc] initWithSquirrelVM: [OCSquirrelVM defaultVM]];
    
    return [self initWithImpl: impl];
}


- (instancetype)initWithCapacity:(NSUInteger)numItems
{
    return [self init];
}


#pragma mark - initialization methods + OCSquirrelVM

- (instancetype)initWithSquirrelVM:(OCSquirrelVM *)squirrelVM
{
    OCSquirrelArrayImpl *impl = [[OCSquirrelArrayImpl alloc] initWithSquirrelVM: squirrelVM];
    
    return [self initWithImpl: impl];
}


- (instancetype)initWithSquirrelVM:(OCSquirrelVM *)squirrelVM
                           objects:(const id [])objects
                             count:(NSUInteger)count
{
    OCSquirrelArrayImpl *impl = [[OCSquirrelArrayImpl alloc] initWithSquirrelVM: squirrelVM];
    
    for (NSUInteger i = 0; i < count; ++i)
    {
        [impl addObject: objects[i]];
    }
    
    return [self initWithImpl: impl];
}


- (instancetype)initWithSquirrelVM:(OCSquirrelVM *)squirrelVM
                           objects:(id)firstObj, ...
{
    OCSquirrelArrayImpl *impl = [[OCSquirrelArrayImpl alloc] initWithSquirrelVM: squirrelVM];
    
    id arg = nil;
    
    va_list args;
    va_start(args, firstObj);
    
    while ((arg = va_arg(args, id)))
    {
        [impl addObject: arg];
    }
    
    va_end(args);
    
    return [self initWithImpl: impl];
}


- (instancetype)initWithSquirrelVM:(OCSquirrelVM *)squirrelVM
                             array:(NSArray *)array
{
    return [self initWithSquirrelVM: squirrelVM
                              array: array
                          copyItems: NO];
}


- (instancetype)initWithSquirrelVM:(OCSquirrelVM *)squirrelVM
                             array:(NSArray *)array
                         copyItems:(BOOL)flag
{
    OCSquirrelArrayImpl *impl = [[OCSquirrelArrayImpl alloc] initWithSquirrelVM: squirrelVM];
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [impl addObject: obj];
    }];
    
    return [self initWithImpl: impl];
}


#pragma mark - NSArray primitive methods

- (NSUInteger)count
{
    return self.impl.count;
}


- (id)objectAtIndex:(NSInteger)index
{
    return [self.impl objectAtIndex: index];
}

#pragma mark - NSMutableArray primitive methods

- (void)insertObject:(id)anObject atIndex:(NSInteger)index
{
    [self.impl insertObject: anObject atIndex: index];
}


- (void)removeObjectAtIndex:(NSInteger)index
{
    [self.impl removeObjectAtIndex: index];
}


- (void)addObject:(id)anObject
{
    [self.impl addObject: anObject];
}


- (void)removeLastObject
{
    [self.impl pop];
}


- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    [self.impl setObject: anObject atIndex: index];
}


#pragma mark - <OCSquirrelObject> methods

- (OCSquirrelVM *)squirrelVM
{
    return self.impl.squirrelVM;
}


- (HSQOBJECT *)obj
{
    return self.impl.obj;
}


- (SQObjectType)type
{
    return self.impl.type;
}


- (void)push
{
    [self.impl push];
}


#pragma mark - <OCSquirrelArray> methods

- (id)objectAtIndexedSubscript:(NSInteger)index
{
    return [self.impl objectAtIndexedSubscript: index];
}


- (void)enumerateObjectsUsingBlock:(void (^)(id object, NSInteger index, BOOL *stop))block
{
    [self.impl enumerateObjectsUsingBlock: block];
}


- (void)setObject:(id)object atIndex:(NSInteger)index
{
    [self.impl setObject: object atIndex: index];
}


- (void)setObject:(id)object atIndexedSubscript:(NSInteger)idx
{
    [self.impl setObject: object atIndexedSubscript: idx];
}


- (id)pop
{
    return [self.impl pop];
}


#pragma mark - <NSCopying>

- (instancetype)copyWithZone:(NSZone *)zone
{
    return [self mutableCopyWithZone: zone];
}


#pragma mark - <NSMutableCopying>

- (instancetype)mutableCopyWithZone:(NSZone *)zone
{
    typeof(self.impl) clonedImpl = [self.impl copyWithZone: zone];
    
    if (clonedImpl == nil) {
        return nil;
    }
    
    return [[self.class allocWithZone: zone] initWithImpl: clonedImpl];
}


@end
