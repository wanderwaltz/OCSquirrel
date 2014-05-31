//
//  OCSquirrelTable.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 26.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "OCSquirrelTable.h"
#import "OCSquirrelTable+Protected.h"
#import "OCSquirrelTableImpl.h"

@implementation OCSquirrelTable

#pragma mark - protected

- (instancetype)initWithImpl:(OCSquirrelTableImpl *)impl
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
    const id objects[0] = {};
    const id keys[0] = {};
    
    return [self initWithObjects: objects forKeys: keys count: 0];
}


- (instancetype)initWithSquirrelVM:(OCSquirrelVM *)vm
                           objects:(const id [])objects
                           forKeys:(const id<NSCopying> [])keys
                             count:(NSUInteger)count
{
    OCSquirrelTableImpl *impl = [[OCSquirrelTableImpl alloc] initWithVM: vm];
    
    for (NSUInteger i = 0; i < count; ++i)
    {
        [impl setObject: objects[i] forKey: keys[i]];
    }
    
    return [self initWithImpl: impl];
}


#pragma mark - NSDictionary primitive methods

- (instancetype)initWithObjects:(const id [])objects
                        forKeys:(const id<NSCopying> [])keys
                          count:(NSUInteger)count
{
    return [self initWithSquirrelVM: [OCSquirrelVM defaultVM]
                            objects: objects
                            forKeys: keys
                              count: count];
}


- (NSUInteger)count
{
    return [self.impl count];
}


- (id) objectForKey: (id) aKey
{
    return [self.impl objectForKey: aKey];
}


- (NSEnumerator *)keyEnumerator
{
    return [self.impl keyEnumerator];
}


#pragma mark - NSMutableDictionary primitive methods

- (void)setObject:(id)anObject
           forKey:(id)aKey
{
    [self.impl setObject: anObject
                  forKey: aKey];
}


- (void)removeObjectForKey:(id)aKey
{
    [self.impl removeObjectForKey: aKey];
     
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



#pragma mark - <OCSquirrelTable> methods

- (SQInteger)integerForKey:(id)key
{
    return [self.impl integerForKey: key];
}


- (SQFloat)floatForKey:(id)key
{
    return [self.impl floatForKey: key];
}


- (BOOL)boolForKey:(id)key
{
    return [self.impl boolForKey: key];
}


- (NSString *)stringForKey:(id)key
{
    return [self.impl stringForKey: key];
}


- (SQUserPointer)userPointerForKey:(id)key
{
    return [self.impl userPointerForKey: key];
}


- (id)objectForKeyedSubscript:(id<NSCopying>)key
{
    return [self.impl objectForKeyedSubscript: key];
}


#pragma mark setter methods

- (void)setObject:(id)object
forKeyedSubscript:(id<NSCopying>)key
{
    [self.impl setObject: object
       forKeyedSubscript: key];
}


- (void)setInteger:(SQInteger)value
             forKey:(id)key
{
    [self.impl setInteger: value
                   forKey: key];
}


- (void)setFloat:(SQFloat)value
          forKey:(id)key
{
    [self.impl setFloat: value
                 forKey: key];
}


- (void)setBool:(BOOL)value
         forKey:(id)key
{
    [self.impl setBool: value
                forKey: key];
}


- (void)setString:(NSString *)value
           forKey:(id)key
{
    [self.impl setString: value
                  forKey: key];
}

- (void)setUserPointer:(SQUserPointer)pointer
                forKey:(id)key
{
    [self.impl setUserPointer: pointer
                       forKey: key];
}


#pragma mark enumeration

- (void)enumerateObjectsAndKeysUsingBlock:(void (^)(id key, id value, BOOL *stop))block
{
    [self.impl enumerateObjectsAndKeysUsingBlock: block];
}


#pragma mark calls

- (id)callClosureWithKey:(id)key
{
    return [self.impl callClosureWithKey: key];
}


- (id)callClosureWithKey:(id)key
              parameters:(NSArray *)parameters
{
    return [self.impl callClosureWithKey: key
                              parameters: parameters];
}

@end
