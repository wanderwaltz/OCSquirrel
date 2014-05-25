//
//  OCSquirrelVM+SQObjects.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 25.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrelVM.h"

@protocol OCSquirrelTable;

@interface OCSquirrelVM (SQObjects)

- (id<OCSquirrelTable>) rootTable;
- (id<OCSquirrelTable>) registryTable;
- (id<OCSquirrelTable>) newTable;
- (id<OCSquirrelTable>) newTableWithHSQObject:(HSQOBJECT)sqObject;

@end
