//
//  OCSquirrelUserData.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 31.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "OCSquirrelUserData.h"
#import "OCSquirrelUserData+Protected.h"
#import "OCSquirrelUserDataImpl.h"


#pragma mark -
#pragma mark OCSquirrelUserData implementation

@implementation OCSquirrelUserData

#pragma mark -
#pragma mark protected

- (instancetype)initWithImpl:(OCSquirrelUserDataImpl *)impl
{
    self = [super init];
    
    if (self != nil) {
        _impl = impl;
    }
    
    return self;
}

#pragma mark -
#pragma mark initialization methods

- (instancetype)initWithObject:(id)object
{
    OCSquirrelUserDataImpl *impl = [[OCSquirrelUserDataImpl alloc] initWithObject: object
                                                                             inVM: [OCSquirrelVM defaultVM]];
    return [self initWithImpl: impl];
}


- (instancetype)initWithObject:(id)object inSquirrelVM:(OCSquirrelVM *)squirrelVM
{
    OCSquirrelUserDataImpl *impl = [[OCSquirrelUserDataImpl alloc] initWithObject: object
                                                                             inVM: squirrelVM];
    return [self initWithImpl: impl];
}


#pragma mark -
#pragma mark <OCSquirrelObject>

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


- (void) push
{
    [self.impl push];
}


#pragma mark -
#pragma mark <OCSquirrelUserData>

- (id)object
{
    return self.impl.object;
}

@end
