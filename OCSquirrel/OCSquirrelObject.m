//
//  OCSquirrelObject.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 14.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "OCSquirrelObject.h"


#pragma mark -
#pragma mark OCSquirrelObject implementation

@implementation OCSquirrelObject

#pragma mark -
#pragma mark properties

- (HSQOBJECT *) obj
{
    return &_obj;
}


- (BOOL) isNull
{
    return sq_isnull(_obj);
}


- (SQObjectType) type
{
    return _obj._type;
}


#pragma mark -
#pragma mark class methods

+ (BOOL) isAllowedToInitWithSQObjectOfType: (SQObjectType) type
{
    return YES;
}


#pragma mark -
#pragma mark initialization methods

- (id) initWithVM: (OCSquirrelVM *) squirrelVM
{
    self = [super init];
    
    if (self != nil)
    {
        _squirrelVM = squirrelVM;
        sq_resetobject(&_obj);        
    }
    return self;
}


- (id) initWithHSQOBJECT: (HSQOBJECT) object
                    inVM: (OCSquirrelVM *) squirrelVM
{
    if ([[self class] isAllowedToInitWithSQObjectOfType: object._type])
    {
        self = [super init];
        
        if (self != nil)
        {
            _squirrelVM = squirrelVM;
            _obj        = object;
            [squirrelVM doWait: ^{
                sq_addref(_squirrelVM.vm, &_obj);
            }];
        }
        return self;
    }
    else return nil;
}


- (void) dealloc
{
    [_squirrelVM doWait: ^{
        sq_release(_squirrelVM.vm, &_obj); 
    }];
}


#pragma mark -
#pragma mark methods

- (void) push
{
    OCSquirrelVM *squirrelVM = self.squirrelVM;
    
    [squirrelVM doWait: ^{
        [squirrelVM.stack pushSQObject: _obj];
    }];
}

@end
