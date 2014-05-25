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


+ (id) newWithVM: (OCSquirrelVM *) squirrelVM
{
    return [[self alloc] initWithVM: squirrelVM];
}


+ (id) newWithHSQOBJECT: (HSQOBJECT) object
                   inVM: (OCSquirrelVM *) squirrelVM
{
    return [[self alloc] initWithHSQOBJECT: object
                                      inVM: squirrelVM];
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
            sq_addref(_squirrelVM.vm, &_obj);
        }
        return self;
    }
    else return nil;
}


- (void) dealloc
{
    if (_squirrelVM.vm) {
        sq_release(_squirrelVM.vm, &_obj);
    }
}


#pragma mark -
#pragma mark methods

- (void) push
{
    OCSquirrelVM *squirrelVM = self.squirrelVM;
    [squirrelVM.stack pushSQObject: _obj];
}


#pragma mark -
#pragma mark NSObject

- (NSString *) description
{
    NSString *type = @"Unknown type";
    
    switch (_obj._type)
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
    
    return [NSString stringWithFormat: @"%@ (%@)", [super description], type];
}

@end
