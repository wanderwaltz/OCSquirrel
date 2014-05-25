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
#import "OCSquirrelClosure.h"


#pragma mark -
#pragma mark OCSquirrelTable implementation

@implementation OCSquirrelTable

#pragma mark -
#pragma mark class methods

+ (BOOL) isAllowedToInitWithSQObjectOfType: (SQObjectType) type
{
    return (type == OT_TABLE);
}


#pragma mark -
#pragma mark initialization methods

+ (id) rootTableForVM: (OCSquirrelVM *) squirrelVM
{
    __block id table = nil;
    
    [squirrelVM performPreservingStackTop: ^(HSQUIRRELVM vm, id<OCSquirrelVMStack> stack){
        sq_pushroottable(vm);
        
        HSQOBJECT root = [stack sqObjectAtPosition: -1];
        
        table = [[self alloc] initWithHSQOBJECT: root
                                           inVM: squirrelVM];
    }];
    
    
    return table;
}


+ (id) registryTableForVM: (OCSquirrelVM *) squirrelVM
{
    __block id table = nil;
    
    [squirrelVM performPreservingStackTop: ^(HSQUIRRELVM vm, id<OCSquirrelVMStack> stack){
        sq_pushregistrytable(vm);
        
        HSQOBJECT registry = [stack sqObjectAtPosition: -1];
        
        table = [[self alloc] initWithHSQOBJECT: registry
                                           inVM: squirrelVM];
    }];
    
    
    return table;
}


- (id) initWithVM: (OCSquirrelVM *) squirrelVM
{
    self = [super initWithVM: squirrelVM];
    
    if (self != nil)
    {
        [squirrelVM performPreservingStackTop: ^(HSQUIRRELVM vm, id<OCSquirrelVMStack> stack){
            sq_newtable(vm);
            _obj = [stack sqObjectAtPosition: -1];
            sq_addref(vm, &_obj);
        }];
    }
    return self;
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
    
    [squirrelVM performPreservingStackTop: ^(HSQUIRRELVM vm, id<OCSquirrelVMStack> stack){
        [self push];
        
        [stack pushValue: key];
        
        if (SQ_SUCCEEDED(sq_get(vm, -2)))
        {
            object = [stack valueAtPosition: -1];
        }
    }];
    
    return object;
}


- (id) objectForKeyedSubscript:(id<NSCopying>)key
{
    return [self objectForKey: key];
}


#pragma mark -
#pragma mark setter objects

- (void) setObject: (id) object forKey: (id) key
{
    OCSquirrelVM *squirrelVM = self.squirrelVM;
    
    [squirrelVM performPreservingStackTop: ^(HSQUIRRELVM vm, id<OCSquirrelVMStack> stack){
        [self push];
        [stack pushValue: key];
        [stack pushValue: object];
        
        sq_newslot(vm, -3, SQFalse);
    }];
}


- (void) setObject:(id)object forKeyedSubscript:(id<NSCopying>)key
{
    [self setObject: object forKey: key];
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


#pragma mark -
#pragma mark key-value coding

- (id) valueForUndefinedKey: (NSString *) key
{
    // Tries to get the value from the underlying Squirrel table.
    return [self objectForKey: key];
}


- (void) setValue: (id) value
  forUndefinedKey: (NSString *) key
{
    // Tries to set the corresponding slot of the underlying Squirrel table
    [self setObject: value forKey: key];
}


#pragma mark -
#pragma mark enumeration

- (void) enumerateObjectsAndKeysUsingBlock: (void (^)(id key, id value, BOOL *stop)) block
{
    if (block != nil)
    {
        OCSquirrelVM *squirrelVM = self.squirrelVM;
        
        [squirrelVM performPreservingStackTop:^(HSQUIRRELVM vm, id<OCSquirrelVMStack> stack){
            
            [self push];
            sq_pushnull(vm);
            
            while(SQ_SUCCEEDED(sq_next(vm, -2)))
            {
                id key   = [stack valueAtPosition: -2];
                id value = [stack valueAtPosition: -1];
                
                sq_pop(vm,2);
                
                BOOL stop = NO;
                
                block(key, value, &stop);
            
                if (stop) break;
            }
        }];
    }
}


#pragma mark -
#pragma mark calls

- (id) callClosureWithKey: (id) key
{
    id closure = [self objectForKey: key];
    
    if ([closure isKindOfClass: [OCSquirrelClosure class]])
    {
        return [closure callWithThis: self];
    }
    else return nil;
}


- (id) callClosureWithKey: (id) key
               parameters: (NSArray *) parameters
{
    id closure = [self objectForKey: key];
    
    if ([closure isKindOfClass: [OCSquirrelClosure class]])
    {
        return [closure callWithThis: self
                          parameters: parameters];
    }
    else return nil;
}


@end
