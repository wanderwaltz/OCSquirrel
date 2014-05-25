//
//  OCSquirrelVM+SQObjects.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 25.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrelVM.h"

// TODO: encapsulate implementations of other OCSquirrelObjects similar to OCSquirrelTable
// Basically each of the Squirrel objects (array, class, instance, closure etc.) should have
// a corresponding @protocol with private impl class backing it and a method of creating those
// objects using OCSquirrelVM+SQObjects category.

// TODO: tests for public OCSquirrelTable-related APIs

@protocol OCSquirrelTable;

@interface OCSquirrelVM (SQObjects)

- (id<OCSquirrelTable>) rootTable;
- (id<OCSquirrelTable>) registryTable;
- (id<OCSquirrelTable>) newTable;
- (id<OCSquirrelTable>) newTableWithHSQObject:(HSQOBJECT)sqObject;

@end
