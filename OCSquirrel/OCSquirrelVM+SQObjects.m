//
//  OCSquirrelVM+SQObjects.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 25.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrelVM+SQObjects.h"
#import "OCSquirrelTableImpl.h"

@implementation OCSquirrelVM (SQObjects)

- (id<OCSquirrelTable>) rootTable
{
    return [OCSquirrelTableImpl rootTableForVM: self];
}


- (id<OCSquirrelTable>) registryTable
{
    return [OCSquirrelTableImpl registryTableForVM: self];
}


- (id<OCSquirrelTable>) newTable
{
    return [[OCSquirrelTableImpl alloc] initWithVM: self];
}


- (id<OCSquirrelTable>) newTableWithHSQObject:(HSQOBJECT)sqObject
{
    return [[OCSquirrelTableImpl alloc] initWithHSQOBJECT: sqObject inVM: self];
}


@end
