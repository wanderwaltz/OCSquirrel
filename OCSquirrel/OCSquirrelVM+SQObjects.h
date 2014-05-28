//
//  OCSquirrelVM+SQObjects.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 25.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrelVM.h"

// TODO: encapsulate implementations of other OCSquirrelObjectImpls similar to OCSquirrelTable
// Basically each of the Squirrel objects (array, class, instance, closure etc.) should have
// a corresponding @protocol with private impl class backing it and a method of creating those
// objects using OCSquirrelVM+SQObjects category.

@class OCSquirrelTable;
@class OCSquirrelArray;
@class OCSquirrelClosure;

@interface OCSquirrelVM (SQObjects)

- (OCSquirrelTable *)rootTable;
- (OCSquirrelTable *)registryTable;
- (OCSquirrelTable *)newTable;
- (OCSquirrelTable *)newTableWithHSQObject:(HSQOBJECT)sqObject;

- (OCSquirrelArray *)newArray;
- (OCSquirrelArray *)newArrayWithHSQObject:(HSQOBJECT)sqObject;

- (OCSquirrelClosure *)newClosureWithSQFUNCTION:(SQFUNCTION)func;
- (OCSquirrelClosure *)newClosureWithSQFUNCTION:(SQFUNCTION)func
                                           name:(NSString *)name;

@end
