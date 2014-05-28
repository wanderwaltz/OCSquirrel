//
//  OCSquirrelObjectImpl.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 14.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "OCSquirrelObjectImpl.h"


#pragma mark -
#pragma mark OCSquirrelObjectImpl implementation

@implementation OCSquirrelObjectImpl

#pragma mark -
#pragma mark properties

- (HSQOBJECT *)obj
{
    return &_obj;
}


- (BOOL)isNull
{
    return sq_isnull(_obj);
}


- (SQObjectType)type
{
    return _obj._type;
}


#pragma mark -
#pragma mark class methods

+ (BOOL)isAllowedToInitWithSQObjectOfType:(SQObjectType)type
{
    return YES;
}


+ (id)newWithVM:(OCSquirrelVM *)squirrelVM
{
    return [[self alloc] initWithVM:squirrelVM];
}


+ (id)newWithHSQOBJECT:(HSQOBJECT)object
                  inVM:(OCSquirrelVM *)squirrelVM
{
    return [[self alloc] initWithHSQOBJECT: object
                                      inVM: squirrelVM];
}


#pragma mark -
#pragma mark initialization methods

- (id)initWithVM:(OCSquirrelVM *)squirrelVM
{
    self = [super init];
    
    if (self != nil)
    {
        _squirrelVM = squirrelVM;
        sq_resetobject(&_obj);        
    }
    return self;
}


- (id)initWithHSQOBJECT:(HSQOBJECT)object
                   inVM:(OCSquirrelVM *)squirrelVM
{
    if ([[self class] isAllowedToInitWithSQObjectOfType: object._type]) {
        self = [super init];
        
        if (self != nil) {
            _squirrelVM = squirrelVM;
            _obj        = object;
            
            [_squirrelVM perform:^(HSQUIRRELVM vm, id<OCSquirrelVMStack> stack) {
                sq_addref(vm, &_obj);
            }];
            
        }
        return self;
    }
    else {
        @throw [NSException exceptionWithName: NSInvalidArgumentException
                                       reason: [NSString stringWithFormat:
                                                @"*** initWithHSQOBJECT:inVM: %@ class does not support initialization "
                                                @"with HSQOBJECT of type %@",
                                                NSStringFromClass(self.class),
                                                [self.class stringForSQObjectType: object._type]]
                                     userInfo: nil];
        return nil;
    }
}


- (void)dealloc
{
    [_squirrelVM perform:^(HSQUIRRELVM vm, id<OCSquirrelVMStack> stack) {
        sq_release(vm, &_obj);
    }];
}


#pragma mark -
#pragma mark methods

- (void)push
{
    OCSquirrelVM *squirrelVM = self.squirrelVM;
    [squirrelVM.stack pushSQObject: _obj];
}


#pragma mark -
#pragma mark NSObject

+ (NSString *)stringForSQObjectType:(SQObjectType)sqType
{
    NSString *type = @"Unknown type";
    
    switch (sqType)
    {
        case OT_NULL:          type = @"OT_NULL";          break;
        case OT_INTEGER:       type = @"OT_INTEGER";       break;
        case OT_FLOAT:         type = @"OT_FLOAT";         break;
        case OT_BOOL:          type = @"OT_BOOL";          break;
        case OT_STRING:        type = @"OT_STRING";        break;
        case OT_TABLE:         type = @"OT_TABLE";         break;
        case OT_ARRAY:         type = @"OT_ARRAY";         break;
        case OT_USERDATA:      type = @"OT_USERDATA";      break;
        case OT_CLOSURE:       type = @"OT_CLOSURE";       break;
        case OT_NATIVECLOSURE: type = @"OT_NATIVECLOSURE"; break;
        case OT_GENERATOR:     type = @"OT_GENERATOR";     break;
        case OT_USERPOINTER:   type = @"OT_USERPOINTER";   break;
        case OT_THREAD:        type = @"OT_THREAD";        break;
        case OT_FUNCPROTO:     type = @"OT_FUNCPROTO";     break;
        case OT_CLASS:         type = @"OT_CLASS";         break;
        case OT_INSTANCE:      type = @"OT_INSTANCE";      break;
        case OT_WEAKREF:       type = @"OT_WEAKREF";       break;
        case OT_OUTER:         type = @"OT_OUTER";         break;
    }
    
    return type;
}

- (NSString *)description
{
    NSString *type = [self.class stringForSQObjectType: _obj._type];
    
    return [NSString stringWithFormat: @"%@ (%@)", [super description], type];
}

@end