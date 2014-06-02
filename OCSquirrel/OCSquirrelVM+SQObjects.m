//
//  OCSquirrelVM+SQObjects.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 25.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrelVM+SQObjects.h"
#import "OCSquirrelVM+Protected.h"
#import "OCSquirrelVMBindings_NoARC.h"

#import "OCSquirrelTable.h"
#import "OCSquirrelTable+Protected.h"
#import "OCSquirrelTableImpl.h"

#import "OCSquirrelArray.h"
#import "OCSquirrelArray+Protected.h"
#import "OCSquirrelArrayImpl.h"

#import "OCSquirrelClosure.h"
#import "OCSquirrelClosure+Protected.h"
#import "OCSquirrelClosureImpl.h"

#import "OCSquirrelUserData.h"
#import "OCSquirrelUserData+Protected.h"
#import "OCSquirrelUserDataImpl.h"

#import "OCSquirrelClass.h"
#import "OCSquirrelClass+Protected.h"
#import "OCSquirrelClassImpl.h"


#pragma mark -
#pragma mark OCSquirrelVM+SQObjects implementation

@implementation OCSquirrelVM (SQObjects)

#pragma mark - OCSquirrelTable

- (id<OCSquirrelTable>) rootTable
{
    return [[OCSquirrelTable alloc] initWithImpl:
            [OCSquirrelTableImpl rootTableForVM: self]];
}


- (id<OCSquirrelTable>) registryTable
{
    return [[OCSquirrelTable alloc] initWithImpl:
            [OCSquirrelTableImpl registryTableForVM: self]];
}


- (id<OCSquirrelTable>) newTable
{
    return [[OCSquirrelTable alloc] initWithImpl:
            [[OCSquirrelTableImpl alloc] initWithSquirrelVM: self]];
}


- (id<OCSquirrelTable>) newTableWithHSQObject:(HSQOBJECT)sqObject
{
    return [[OCSquirrelTable alloc] initWithImpl:
            [[OCSquirrelTableImpl alloc] initWithSquirrelVM: self
                                                  HSQOBJECT: sqObject]];
}


#pragma mark - OCSquirrelArray

- (OCSquirrelArray *)newArray
{
    return [[OCSquirrelArray alloc] initWithImpl:
            [[OCSquirrelArrayImpl alloc] initWithSquirrelVM: self]];
}


- (OCSquirrelArray *)newArrayWithHSQObject:(HSQOBJECT)sqObject
{
    return [[OCSquirrelArray alloc] initWithImpl:
            [[OCSquirrelArrayImpl alloc] initWithSquirrelVM: self
                                                  HSQOBJECT: sqObject]];
}


#pragma mark - OCSquirrelClosure

- (OCSquirrelClosure *)newClosureWithSQFUNCTION:(SQFUNCTION)func
{
    return [[OCSquirrelClosure alloc] initWithImpl:
            [[OCSquirrelClosureImpl alloc] initWithSQFUNCTION: func
                                                   squirrelVM: self]];
}


- (OCSquirrelClosure *)newClosureWithSQFUNCTION:(SQFUNCTION)func
                                           name:(NSString *)name
{
    return [[OCSquirrelClosure alloc] initWithImpl:
            [[OCSquirrelClosureImpl alloc] initWithSQFUNCTION: func
                                                         name: name
                                                   squirrelVM: self]];
}


- (OCSquirrelClosure *)newClosureWithBlock:(id)block
{
    return [[OCSquirrelClosure alloc] initWithImpl:
            [[OCSquirrelClosureImpl alloc] initWithBlock: block
                                              squirrelVM: self]];
}


- (OCSquirrelClosure *)newClosureWithBlock:(id)block
                                      name:(NSString *)name
{
    return [[OCSquirrelClosure alloc] initWithImpl:
            [[OCSquirrelClosureImpl alloc] initWithBlock: block
                                                    name: name
                                              squirrelVM: self]];
}


#pragma mark - OCSquirrelUserData

- (OCSquirrelUserData *)newUserDataWithObject:(id)object
{
    return [[OCSquirrelUserData alloc] initWithImpl:
            [[OCSquirrelUserDataImpl alloc] initWithObject: object
                                                      inVM: self]];
}


#pragma mark - OCSquirrelClass

- (OCSquirrelClass *)bindClass:(Class)nativeClass;
{
    NSString *className = NSStringFromClass(nativeClass);
    
    __block OCSquirrelClass *squirrelClass = _classBindings[className];
    
    if (squirrelClass != nil) {
        return squirrelClass;
    }
    
    [self performPreservingStackTop:^(HSQUIRRELVM vm, id<OCSquirrelVMStack> stack){
        OCSquirrelClassImpl *impl = [[OCSquirrelClassImpl alloc] initWithNativeClass: nativeClass inVM: self];
        
        if (impl == nil) {
            return;
        }
        
        // Bind constructor. Note that the constructor only does alloc
        // an instance of the native class without initializing it,
        // so further calls to -init or other initializers should be
        // then immediately performed using one of the bound initializer
        // methods.
        id constructor =
        [[OCSquirrelClosureImpl alloc] initWithSQFUNCTION: OCSquirrelVMBindings_Constructor
                                               squirrelVM: self];
        [impl setObject: constructor forKey: @"constructor"];
        
        squirrelClass = [[OCSquirrelClass alloc] initWithImpl: impl];
        
        _classBindings[className] = squirrelClass;
    }];
    
    return squirrelClass;
}


@end
