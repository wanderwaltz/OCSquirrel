//
//  OCSquirrelClass.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 27.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "OCSquirrelClass.h"

#pragma mark -
#pragma mark OCSquirrelClass implementation

@implementation OCSquirrelClass

#pragma mark -
#pragma mark properties

- (Class) nativeClass
{
    Class class   = nil;
    id attributes = [self classAttributes];
    
    if ([attributes isKindOfClass: [NSValue class]])
    {
        class = (__bridge Class)[attributes pointerValue];
    }
    
    return class;
}


#pragma mark -
#pragma mark class methods

+ (BOOL) isAllowedToInitWithSQObjectOfType: (SQObjectType) type
{
    return (type == OT_CLASS);
}


#pragma mark -
#pragma mark initialization methods

- (id) initWithVM: (OCSquirrelVM *) squirrelVM
{
    self = [super initWithVM: squirrelVM];
    
    if (self != nil)
    {
        [squirrelVM doWaitPreservingStackTop: ^{
            sq_newclass(squirrelVM.vm, SQFalse);
            sq_getstackobj(squirrelVM.vm, -1, &_obj);
            sq_addref(squirrelVM.vm, &_obj);
        }];
    }
    return self;
}


#pragma mark -
#pragma mark class attributes

- (void) setClassAttributes: (id) attributes
{
    OCSquirrelVM *squirrelVM = self.squirrelVM;
    
    [squirrelVM doWaitPreservingStackTop: ^{
        [self push];
        sq_pushnull(squirrelVM.vm);
        [squirrelVM.stack pushValue: attributes];
        
        sq_setattributes(squirrelVM.vm, -3);
    }];
}


- (id) classAttributes
{
    __block id value = nil;
    
    OCSquirrelVM *squirrelVM = self.squirrelVM;
    
    [squirrelVM doWaitPreservingStackTop: ^{
        [self push];
        sq_pushnull(squirrelVM.vm);
        sq_getattributes(squirrelVM.vm, -2);
        
        value = [squirrelVM.stack valueAtPosition: -1];
    }];
    
    return value;
}


@end
