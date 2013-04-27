//
//  OCSquirrelTable.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 14.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "OCSquirrelTable.h"


#pragma mark -
#pragma mark OCSquirrelTable implementation

@implementation OCSquirrelTable

#pragma mark -
#pragma mark initialization methods

+ (id) rootTableForVM: (OCSquirrelVM *) squirrelVM
{
    __block id table = nil;
    
    [squirrelVM doWaitPreservingStackTop: ^{
        sq_pushroottable(squirrelVM.vm);
        
        HSQOBJECT root = [squirrelVM.stack sqObjectAtPosition: -1];
        
        table = [[self alloc] initWithHSQOBJECT: root
                                           inVM: squirrelVM];
    }];
    
    
    return table;
}


- (id) initWithVM: (OCSquirrelVM *) squirrelVM
{
    self = [super initWithVM: squirrelVM];
    
    if (self != nil)
    {
        [squirrelVM doWaitPreservingStackTop: ^{
            sq_newtable(squirrelVM.vm);
            _obj = [squirrelVM.stack sqObjectAtPosition: -1];
            sq_addref(squirrelVM.vm, &_obj);
        }];
    }
    return self;
}


- (id) initWithHSQOBJECT: (HSQOBJECT) object
                    inVM: (OCSquirrelVM *) squirrelVM
{
    if (sq_type(object) == OT_TABLE)
    {
        return [super initWithHSQOBJECT: object
                                   inVM: squirrelVM];
    }
    else return nil;
}


#pragma mark -
#pragma mark getter methods

- (SQInteger) integerForKey: (id) key
{
    id object = [self objectForKey: key];
    
    if ([object isKindOfClass: [NSNumber class]])
    {
        return (SQInteger)[object integerValue];
    }
    else return 0;
}


- (SQFloat) floatForKey: (id) key
{
    id object = [self objectForKey: key];
    
    if ([object isKindOfClass: [NSNumber class]])
    {
        return (SQFloat)[object doubleValue];
    }
    else return 0.0;
}


- (BOOL) boolForKey: (id) key
{
    id object = [self objectForKey: key];
    
    if ([object isKindOfClass: [NSNumber class]])
    {
        return [object boolValue];
    }
    else return NO;
}


- (NSString *) stringForKey: (id) key
{
    id object = [self objectForKey: key];
    
    if ([object isKindOfClass: [NSString class]])
    {
        return object;
    }
    else return nil;
}


- (SQUserPointer) userPointerForKey: (id) key
{
    id object = [self objectForKey: key];
    
    if ([object isKindOfClass: [NSValue class]])
    {
        return [object pointerValue];
    }
    else return NULL;
}


- (id) objectForKey: (id) key
{
    __block id object = nil;
    
    OCSquirrelVM *squirrelVM = self.squirrelVM;
    
    [squirrelVM doWaitPreservingStackTop: ^{
        [self push];
        
        [squirrelVM.stack pushValue: key];
        
        if (SQ_SUCCEEDED(sq_get(squirrelVM.vm, -2)))
        {
            object = [squirrelVM.stack valueAtPosition: -1];
        }
    }];
    
    return object;
}


#pragma mark -
#pragma mark setter objects

- (void) setObject: (id) object forKey: (id) key
{
    OCSquirrelVM *squirrelVM = self.squirrelVM;
    
    [squirrelVM doWaitPreservingStackTop: ^{
        [self push];
        [squirrelVM.stack pushValue: key];
        [squirrelVM.stack pushValue: object];
        
        sq_newslot(squirrelVM.vm, -3, SQFalse);
    }];
}


- (void) setInteger: (SQInteger) value forKey: (id) key
{
    [self setObject: @(value) forKey: key];
}


- (void) setFloat: (SQFloat) value forKey: (id) key
{
    [self setObject: @(value) forKey: key];
}


- (void) setBool: (BOOL) value forKey: (id) key
{
    [self setObject: @(value) forKey: key];
}


- (void) setString: (NSString *) value forKey: (id) key
{
    [self setObject: value forKey: key];
}


- (void) setUserPointer: (SQUserPointer) pointer forKey: (id) key
{
    [self setObject: [NSValue valueWithPointer: pointer] forKey: key];
}


@end
