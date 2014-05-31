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

#import "OCSquirrel.h"
#import "OCSquirrelVMStackImpl.h"
#import "OCSquirrelVM+Protected.h"

#import "OCSquirrelTable+Protected.h"
#import "OCSquirrelArray+Protected.h"
#import "OCSquirrelClosure+Protected.h"
#import "OCSquirrelUserData+Protected.h"
#import "OCSquirrelClass+Protected.h"
#import "OCSquirrelInstance+Protected.h"

#import "OCSquirrelClosureImpl.h"
#import "OCSquirrelArrayImpl.h"
#import "OCSquirrelUserDataImpl.h"
#import "OCSquirrelClassImpl.h"
#import "OCSquirrelInstanceImpl.h"

#pragma mark -
#pragma mark OCSquirrelVMStackImpl implementation

@implementation OCSquirrelVMStackImpl

#pragma mark -
#pragma mark properties

- (NSInteger) top
{
    return sq_gettop(_squirrelVM.vm);
}


- (void) setTop: (NSInteger) top
{
    sq_settop(_squirrelVM.vm, top);
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
    sq_pushinteger(_squirrelVM.vm, value);
}


- (void) pushFloat: (SQFloat) value
{
    sq_pushfloat(_squirrelVM.vm, value);
}


- (void) pushBool: (BOOL) value
{
    sq_pushbool(_squirrelVM.vm, (value) ? SQTrue : SQFalse);
}


- (void) pushNull
{
    sq_pushnull(_squirrelVM.vm);
}


- (void) pushUserPointer: (SQUserPointer) pointer
{
    sq_pushuserpointer(_squirrelVM.vm, pointer);
}


- (void) pushSQObject: (HSQOBJECT) object
{
    sq_pushobject(_squirrelVM.vm, object);
}


- (void) pushString: (NSString *) string
{
    const SQChar *cString = [string cStringUsingEncoding: NSUTF8StringEncoding];
    sq_pushstring(_squirrelVM.vm, cString, scstrlen(cString));
}


- (void) pushValue: (id) value
{
    if ([value conformsToProtocol: @protocol(OCSquirrelObject)])
    {
        [value push];
    }
    else if ([value isKindOfClass: [NSNumber class]])
    {
        const char *objCType = [value objCType];
        
        if ((strcmp(objCType, @encode(float))  == 0) ||
            (strcmp(objCType, @encode(double)) == 0))
        {
            [self pushFloat: (SQFloat)[value doubleValue]];
        }
        else if ((strcmp(objCType, @encode(BOOL)) == 0) ||
                 (strcmp(objCType, @encode(bool)) == 0) ||
                 (strcmp(objCType, [@YES objCType]) == 0))
        {
            [self pushBool: [value boolValue]];
        }
        else
        {
            [self pushInteger: (SQInteger)[value integerValue]];
        }
    }
    else if ([value isKindOfClass: [NSValue class]] &&
             (strcmp([value objCType], @encode(void *)) == 0))
    {
        [self pushUserPointer: [value pointerValue]];
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
        [self pushUserPointer: (__bridge void *)value];
        /*
        @throw [NSException exceptionWithName: NSInvalidArgumentException
                                       reason:
                [NSString stringWithFormat:
                 @"*** pushValue: unsupported value of class %@ received: %@",
                 [value class], value]
                                     userInfo: nil];
         */
    }
}


#pragma mark -
#pragma mark reading methods

- (SQInteger) integerAtPosition: (SQInteger) position
{
    SQInteger value = 0;
    sq_getinteger(_squirrelVM.vm, position, &value);
    
    return value;
}


- (SQFloat) floatAtPosition: (SQInteger) position
{
    SQFloat value = 0.0;
    sq_getfloat(_squirrelVM.vm, position, &value);

    return value;
}


- (BOOL) boolAtPosition: (SQInteger) position
{
    SQBool value = SQFalse;
    sq_getbool(_squirrelVM.vm, position, &value);
    
    return (value == SQTrue) ? YES : NO;
}


- (SQUserPointer) userPointerAtPosition: (SQInteger) position
{
    SQUserPointer pointer = NULL;
    sq_getuserpointer(_squirrelVM.vm, position, &pointer);
    
    return pointer;
}


- (NSString *) stringAtPosition: (SQInteger) position
{
    const SQChar *cString = NULL;
    sq_getstring(_squirrelVM.vm, position, &cString);
    
    if (cString != NULL)
    {
        return [[NSString alloc] initWithCString: cString
                                        encoding: NSUTF8StringEncoding];
    }
    else return nil;
}


- (HSQOBJECT) sqObjectAtPosition: (SQInteger) position
{
    HSQOBJECT object;
    sq_resetobject(&object);
    sq_getstackobj(_squirrelVM.vm, position, &object);
    
    return object;
}


- (id) valueAtPosition: (SQInteger) position
{
    id value = nil;
    
    switch (sq_gettype(_squirrelVM.vm, position))
    {
        case OT_INTEGER:
        {
            value = @([self integerAtPosition: position]);
        } break;
            
        case OT_FLOAT:
        {
            value = @([self floatAtPosition: position]);
        } break;
            
        case OT_BOOL:
        {
            value = @([self boolAtPosition: position]);
        } break;
            
        case OT_USERPOINTER:
        {
            value = [NSValue valueWithPointer: [self userPointerAtPosition: position]];
        } break;
            
        case OT_STRING:
        {
            value = [self stringAtPosition: position];
        } break;
            
        case OT_NULL:
        {
            value = nil;
        } break;
            
        case OT_TABLE:
        {
            HSQOBJECT table = [self sqObjectAtPosition: position];
            
            OCSquirrelTableImpl *impl = [[OCSquirrelTableImpl alloc] initWithHSQOBJECT: table
                                                                                  inVM: _squirrelVM];
            
            value = [[OCSquirrelTable alloc] initWithImpl: impl];
        } break;
            
        case OT_ARRAY:
        {
            HSQOBJECT array = [self sqObjectAtPosition: position];
            
            OCSquirrelArrayImpl *impl = [[OCSquirrelArrayImpl alloc] initWithHSQOBJECT: array
                                                                                  inVM: _squirrelVM];
            
            value = [[OCSquirrelArray alloc] initWithImpl: impl];
            
        } break;
            
        case OT_CLASS:
        {
            HSQOBJECT class = [self sqObjectAtPosition: position];
            
            
            // First check if the class is one of the bound classes,
            // then we already have an OCSquirrelClassImpl instance corresponding
            // to it and there is no need to create more.
            SQUserPointer nativeClass = NULL;
            sq_gettypetag(_squirrelVM.vm, position, &nativeClass);
            
            if (nativeClass != NULL)
            {
                Class class = (__bridge Class)nativeClass;
                NSString *className = NSStringFromClass(class);
                
                if (className != nil)
                {
                    value = _squirrelVM.classBindings[className];
                }
            }
            
            // If existing instance was not found, return a new one.
            if (value == nil) {
                OCSquirrelClassImpl *impl = [[OCSquirrelClassImpl alloc] initWithHSQOBJECT: class
                                                                                      inVM: _squirrelVM];
                
                value = [[OCSquirrelClass alloc] initWithImpl: impl];
            }
        } break;
            
        case OT_INSTANCE:
        {
            HSQOBJECT instance = [self sqObjectAtPosition: position];
            
            OCSquirrelInstanceImpl *impl = [[OCSquirrelInstanceImpl alloc] initWithHSQOBJECT: instance
                                                                                        inVM: _squirrelVM];
            
            value = [[OCSquirrelInstance alloc] initWithImpl: impl];
        } break;
            
            
        case OT_CLOSURE:
        case OT_NATIVECLOSURE:
        {
            HSQOBJECT instance = [self sqObjectAtPosition: position];
            
            OCSquirrelClosureImpl *impl = [[OCSquirrelClosureImpl alloc] initWithHSQOBJECT: instance
                                                                                      inVM: _squirrelVM];
            
            value = [[OCSquirrelClosure alloc] initWithImpl: impl];
        } break;
            
            
        case OT_USERDATA:
        {
            HSQOBJECT object = [self sqObjectAtPosition: position];
            
            OCSquirrelUserDataImpl *impl = [[OCSquirrelUserDataImpl alloc] initWithHSQOBJECT: object
                                                                                        inVM: _squirrelVM];
            
            value = [[OCSquirrelUserData alloc] initWithImpl: impl];
        } break;
            
            
        default:
        {
            HSQOBJECT object = [self sqObjectAtPosition: position];
            
            value = [[OCSquirrelObjectImpl alloc] initWithHSQOBJECT: object
                                                               inVM: _squirrelVM];
        } break;
    }
    
    return value;
}


#pragma mark -
#pragma mark type information

- (BOOL) isNullAtPosition: (SQInteger) position
{
    return (sq_gettype(_squirrelVM.vm, position) == OT_NULL);
}

@end
