//
//  OCSquirrelVM+SQObjects.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 25.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrelVM+SQObjects.h"
#import "OCSquirrelTableImpl.h"
#import "OCSquirrelTable.h"
#import "OCSquirrelTable_Protected.h"

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


@end
