//
//  OCSquirrelVM+SQObjects.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 25.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrelVM+SQObjects.h"

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
            [[OCSquirrelTableImpl alloc] initWithVM: self]];
}


- (id<OCSquirrelTable>) newTableWithHSQObject:(HSQOBJECT)sqObject
{
    return [[OCSquirrelTable alloc] initWithImpl:
            [[OCSquirrelTableImpl alloc] initWithHSQOBJECT: sqObject
                                                      inVM: self]];
}


#pragma mark - OCSquirrelArray

- (OCSquirrelArray *)newArray
{
    return [[OCSquirrelArray alloc] initWithImpl:
            [[OCSquirrelArrayImpl alloc] initWithVM: self]];
}


- (OCSquirrelArray *)newArrayWithHSQObject:(HSQOBJECT)sqObject
{
    return [[OCSquirrelArray alloc] initWithImpl:
            [[OCSquirrelArrayImpl alloc] initWithHSQOBJECT: sqObject
                                                      inVM: self]];
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

@end
