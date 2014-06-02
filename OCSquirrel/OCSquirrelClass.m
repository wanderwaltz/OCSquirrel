//
//  OCSquirrelClass.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 01.06.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "OCSquirrelClass.h"
#import "OCSquirrelClass+Protected.h"
#import "OCSquirrelClassImpl.h"


#pragma mark - OCSquirrelClass implementation

@implementation OCSquirrelClass

#pragma mark - protected

- (instancetype)initWithImpl:(OCSquirrelClassImpl *)impl
{
    self = [super init];
    
    if (self != nil) {
        _impl = impl;
    }
    
    return self;
}


#pragma mark - initialization methods

- (instancetype)initWithNativeClass:(Class)nativeClass inVM:(OCSquirrelVM *)squirrelVM
{
    OCSquirrelClassImpl *impl = [[OCSquirrelClassImpl alloc] initWithNativeClass: nativeClass
                                                                            inVM: squirrelVM];
    
    return [self initWithImpl: impl];
}


- (instancetype)initWithSquirrelVM:(OCSquirrelVM *)squirrelVM
{
    OCSquirrelClassImpl *impl = [[OCSquirrelClassImpl alloc] initWithSquirrelVM: squirrelVM];
    
    return [self initWithImpl: impl];
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


#pragma mark - <OCSquirrelClass>

- (Class)nativeClass
{
    return self.impl.nativeClass;
}


- (id)classAttributes
{
    return self.impl.classAttributes;
}


- (void)setClassAttributes:(id)attributes
{
    self.impl.classAttributes = attributes;
}


- (void)pushNewInstance
{
    [self.impl pushNewInstance];
}


- (BOOL)bindInstanceMethodWithSelector:(SEL)selector error:(NSError *__autoreleasing *)error
{
    return [self.impl bindInstanceMethodWithSelector: selector error: error];
}

@end
