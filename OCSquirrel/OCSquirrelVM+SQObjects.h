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
@class OCSquirrelUserData;
@class OCSquirrelClass;


#pragma mark - OCSquirrelVM+SQObjects interface

@interface OCSquirrelVM (SQObjects)

#pragma mark - tables

- (OCSquirrelTable *)rootTable;
- (OCSquirrelTable *)registryTable;
- (OCSquirrelTable *)newTable;
- (OCSquirrelTable *)newTableWithHSQObject:(HSQOBJECT)sqObject;

#pragma mark - arrays

- (OCSquirrelArray *)newArray;
- (OCSquirrelArray *)newArrayWithHSQObject:(HSQOBJECT)sqObject;

#pragma mark - closures

- (OCSquirrelClosure *)newClosureWithSQFUNCTION:(SQFUNCTION)func;
- (OCSquirrelClosure *)newClosureWithSQFUNCTION:(SQFUNCTION)func
                                           name:(NSString *)name;
- (OCSquirrelClosure *)newClosureWithBlock:(id)block;
- (OCSquirrelClosure *)newClosureWithBlock:(id)block
                                      name:(NSString *)name;

#pragma mark - user data

- (OCSquirrelUserData *)newUserDataWithObject:(id)object;

#pragma mark - classes

- (OCSquirrelClass *)bindClass:(Class)theClass;

@end
