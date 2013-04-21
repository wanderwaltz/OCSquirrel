//
//  OCSquirrelVMStackImpl.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 14.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "OCSquirrelVMStackImpl.h"
#import "OCSquirrelVM+Protected.h"

#pragma mark -
#pragma mark OCSquirrelVMStackImpl implementation

@implementation OCSquirrelVMStackImpl

#pragma mark -
#pragma mark properties

- (NSInteger) top
{
    __block NSInteger top = 0;
    
    [_squirrelVM doWait: ^{
        top = sq_gettop(_squirrelVM.vm);
    }];
    
    return top;
}


- (void) setTop: (NSInteger) top
{
    [_squirrelVM doWait: ^{
        sq_settop(_squirrelVM.vm, top);
    }];
}


#pragma mark -
#pragma mark initialization methods

- (id) initWithSquirrelVM: (OCSquirrelVM *) squirrelVM
{
    self = [super init];
    
    if (self != nil)
    {
        _squirrelVM = squirrelVM;
    }
    return self;
}


#pragma mark -
#pragma mark pushing methods

- (void) pushInteger: (SQInteger) value
{
    [_squirrelVM doWait: ^{
        sq_pushinteger(_squirrelVM.vm, value);
    }];
}


- (void) pushFloat: (SQFloat) value
{
    [_squirrelVM doWait: ^{
        sq_pushfloat(_squirrelVM.vm, value);
    }];
}


- (void) pushBool: (BOOL) value
{
    [_squirrelVM doWait: ^{
        sq_pushbool(_squirrelVM.vm, (value) ? SQTrue : SQFalse);
    }];
}


- (void) pushNull
{
    [_squirrelVM doWait: ^{
        sq_pushnull(_squirrelVM.vm);
    }];
}


- (void) pushUserPointer: (SQUserPointer) pointer
{
    [_squirrelVM doWait: ^{
        sq_pushuserpointer(_squirrelVM.vm, pointer);
    }];
}


- (void) pushSQObject: (HSQOBJECT) object
{
    [_squirrelVM doWait: ^{
        sq_pushobject(_squirrelVM.vm, object);
    }];
}


- (void) pushString: (NSString *) string
{
    [_squirrelVM doWait: ^{
        const SQChar *cString = [string cStringUsingEncoding: NSUTF8StringEncoding];
        sq_pushstring(_squirrelVM.vm, cString, scstrlen(cString));
    }];
}


- (void) pushValue: (id) value
{
    if ([value isKindOfClass: [NSNumber class]])
    {
        const char *objCType = [value objCType];
        
        if ((strcmp(objCType, @encode(float))  == 0) ||
            (strcmp(objCType, @encode(double)) == 0))
        {
            [self pushFloat: (SQFloat)[value doubleValue]];
        }
        else
        {
            [self pushInteger: (SQInteger)[value integerValue]];
        }
    }
    else if ([value isKindOfClass: [NSString class]])
    {
        [self pushString: value];
    }
    else if ([value isKindOfClass: [NSNull class]])
    {
        [self pushNull];
    }
    else if (value == nil)
    {
        [self pushNull];
    }
    else
    {
        @throw [NSException exceptionWithName: NSInvalidArgumentException
                                       reason:
                [NSString stringWithFormat:
                 @"*** pushValue: unsupported value of class %@ received: %@",
                 [value class], value]
                                     userInfo: nil];
    }
}


#pragma mark -
#pragma mark reading methods

- (SQInteger) integerAtPosition: (SQInteger) position
{
    __block SQInteger value = 0;
    
    [_squirrelVM doWait: ^{
        sq_getinteger(_squirrelVM.vm, position, &value);
    }];
    
    return value;
}


- (SQFloat) floatAtPosition: (SQInteger) position
{
    __block SQFloat value = 0.0;
    
    [_squirrelVM doWait: ^{
        sq_getfloat(_squirrelVM.vm, position, &value);
    }];
    
    return value;
}


- (BOOL) boolAtPosition: (SQInteger) position
{
    __block SQBool value = SQFalse;
    
    [_squirrelVM doWait: ^{
        sq_getbool(_squirrelVM.vm, position, &value);
    }];
    
    return (value == SQTrue) ? YES : NO;
}


- (SQUserPointer) userPointerAtPosition: (SQInteger) position
{
    __block SQUserPointer pointer = NULL;
    
    [_squirrelVM doWait: ^{
        sq_getuserpointer(_squirrelVM.vm, position, &pointer);
    }];
    
    return pointer;
}


- (NSString *) stringAtPosition: (SQInteger) position
{
    __block const SQChar *cString = NULL;
    
    [_squirrelVM doWait: ^{
        sq_getstring(_squirrelVM.vm, position, &cString);
    }];
    
    if (cString != NULL)
    {
        return [[NSString alloc] initWithCString: cString
                                        encoding: NSUTF8StringEncoding];
    }
    else return nil;
}


- (HSQOBJECT) sqObjectAtPosition: (SQInteger) position
{
    __block HSQOBJECT object;
    sq_resetobject(&object);
    
    [_squirrelVM doWait: ^{
        sq_getstackobj(_squirrelVM.vm, position, &object);
    }];
    
    return object;
}


#pragma mark -
#pragma mark type information

- (BOOL) isNullAtPosition: (SQInteger) position
{
    __block BOOL isNull = NO;
    
    [_squirrelVM doWait: ^{
        isNull = (sq_gettype(_squirrelVM.vm, position) == OT_NULL);
    }];
    
    return isNull;
}

@end
