//
//  OCSquirrelClosure.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 28.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrelClosure.h"
#import "OCSquirrelClosure+Protected.h"
#import "OCSquirrelClosureImpl.h"

@implementation OCSquirrelClosure

#pragma mark - protected

- (instancetype)initWithImpl:(OCSquirrelClosureImpl *)impl
{
    self = [super init];
    
    if (self != nil) {
        _impl = impl;
    }
    
    return self;
}


#pragma mark - initialization methods

- (instancetype)initWithSQFUNCTION:(SQFUNCTION)function
                        squirrelVM:(OCSquirrelVM *)squirrelVM
{
    OCSquirrelClosureImpl *impl = [[OCSquirrelClosureImpl alloc] initWithSQFUNCTION: function
                                                                         squirrelVM: squirrelVM];
    return [self initWithImpl: impl];
}


- (instancetype)initWithSQFUNCTION:(SQFUNCTION)function
                              name:(NSString *)name
                        squirrelVM:(OCSquirrelVM *)squirrelVM
{
    OCSquirrelClosureImpl *impl = [[OCSquirrelClosureImpl alloc] initWithSQFUNCTION: function
                                                                               name: name
                                                                         squirrelVM: squirrelVM];
    return [self initWithImpl: impl];
}


- (instancetype)initWithBlock:(id)block
                   squirrelVM:(OCSquirrelVM *)squirrelVM
{
    OCSquirrelClosureImpl *impl = [[OCSquirrelClosureImpl alloc] initWithBlock: block
                                                                    squirrelVM: squirrelVM];
    return [self initWithImpl: impl];
}


- (instancetype)initWithBlock:(id)block
                         name:(NSString *)name
                   squirrelVM:(OCSquirrelVM *)squirrelVM
{
    OCSquirrelClosureImpl *impl = [[OCSquirrelClosureImpl alloc] initWithBlock: block
                                                                          name: name
                                                                    squirrelVM: squirrelVM];
    return [self initWithImpl: impl];
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


#pragma mark - <OCSquirrelClosure> methods

- (id)call
{
    return [self.impl call];
}


- (id)call:(NSArray *)parameters
{
    return [self.impl call: parameters];
}


- (id)callWithThis:(id<OCSquirrelObject>)thisObject
{
    return [self.impl callWithThis: thisObject];
}


- (id)callWithThis:(id<OCSquirrelObject>)thisObject
        parameters:(NSArray *)parameters
{
    return [self.impl callWithThis: thisObject
                        parameters: parameters];
}


@end
