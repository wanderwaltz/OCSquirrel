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


#pragma mark -
#pragma mark reading methods

- (SQInteger) integerAtPosition: (SQInteger) position
{
    __block SQInteger value = 0;
    
    [_squirrelVM doWait:^{
        sq_getinteger(_squirrelVM.vm, position, &value);
    }];
    
    return value;
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

@end
