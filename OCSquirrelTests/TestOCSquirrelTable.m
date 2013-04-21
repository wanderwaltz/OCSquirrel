//
//  TestOCSquirrelTable.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 14.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "TestOCSquirrelTable.h"


#pragma mark -
#pragma mark TestOCSquirrelTable implementation

@implementation TestOCSquirrelTable

- (void) setUp
{
    [super setUp];
    _squirrelVM = [[OCSquirrelVM alloc] init];
}


- (void) tearDown
{
    _squirrelVM = nil;
    [super tearDown];
}


- (void) testOCSquirrelTableClassExists
{
    STAssertTrue([OCSquirrelTable isSubclassOfClass: [OCSquirrelObject class]],
                @"OCSquirrelTable class should exist and be a subclass of OCSquirrelObject");
}


- (void) testNotNilWhenInitializingWithTable
{
    sq_pushroottable(_squirrelVM.vm);
    
    HSQOBJECT root;
    
    sq_getstackobj(_squirrelVM.vm, -1, &root);
    
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithHSQOBJECT: root
                                                                   inVM: _squirrelVM];
    
    STAssertNotNil(table,
                   @"OCSquirrelTable should support initializing with an existing table HSQOBJECT");
}


- (void) testNilWhenInitializingWithNull
{
    HSQOBJECT obj;
    sq_resetobject(&obj);
    
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithHSQOBJECT: obj
                                                                   inVM: _squirrelVM];
    STAssertNil(table,
                @"OCSquirrelTable should return nil when initializing with a `null` HSQOBJECT");
}


- (void) testIntForKey
{
    sq_newtable(_squirrelVM.vm);
    
    HSQOBJECT sqTable;
    
    sq_getstackobj(_squirrelVM.vm, -1, &sqTable);
    
    sq_pushstring(_squirrelVM.vm, _SC("someKey"), scstrlen("someKey"));
    
    [_squirrelVM.stack pushInteger: 1234];
    
    sq_newslot(_squirrelVM.vm, -3, SQFalse);
    
    OCSquirrelTable *table = [[OCSquirrelTable alloc] initWithHSQOBJECT: sqTable
                                                                   inVM: _squirrelVM];
    
    STAssertEquals([table integerForKey: @"someKey"], 1234,
                   @"The value set through Squirrel API should be accessible "
                   @"using OCSquirrelTable methods");
}


@end
