//
//  OCSquirrelInstance.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 01.06.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "OCSquirrelInstance.h"
#import "OCSquirrelInstance+Protected.h"
#import "OCSquirrelInstanceImpl.h"

#pragma mark - OCSquirrelInstance implementation

@implementation OCSquirrelInstance

#pragma mark - protected

- (instancetype)initWithImpl:(OCSquirrelInstanceImpl *)impl
{
    self = [super init];
    
    if (self != nil) {
        _impl = impl;
    }
    
    return self;
}


#pragma mark - <OCSquirrelObject>

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


#pragma mark - <OCSquirrelInstance>

- (id)instanceUP
{
    return self.impl.instanceUP;
}

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


- (id)objectForKey:(id)key
{
    return [self.impl objectForKey: key];
}


- (id)objectForKeyedSubscript:(id<NSCopying>)key
{
    return [self.impl objectForKeyedSubscript: key];
}


- (void)setObject:(id)object forKey:(id)key
{
    [self.impl setObject: object forKey: key];
}


- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)key
{
    [self.impl setObject: object forKeyedSubscript: key];
}


@end
