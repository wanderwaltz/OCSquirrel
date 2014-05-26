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

@implementation OCSquirrelVM (SQObjects)

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



@end
