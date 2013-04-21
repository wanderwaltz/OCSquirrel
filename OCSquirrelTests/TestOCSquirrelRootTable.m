//
//  TestOCSquirrelRootTable.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 21.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "TestOCSquirrelRootTable.h"


#pragma mark -
#pragma mark TestOCSquirrelRootTable implementation

@implementation TestOCSquirrelRootTable

- (void) setUp
{
    [super setUp];
    _squirrelVM = [OCSquirrelVM new];
    _rootTable  = [[OCSquirrelRootTable alloc] initWithVM: _squirrelVM];
}


- (void) tearDown
{
    _rootTable  = nil;
    _squirrelVM = nil;
    [super tearDown];
}


- (void) testOCSquirrelRootTableClassExists
{
    STAssertTrue([OCSquirrelRootTable isSubclassOfClass: [OCSquirrelTable class]],
                 @"OCSquirrelRootTable class should exist and be a subclass of OCSquirrelTable");
}


- (void) testObjIsRootTable
{
    sq_pushroottable(_squirrelVM.vm);
    
    HSQOBJECT root = [_squirrelVM.stack sqObjectAtPosition: -1];

    STAssertEquals(*_rootTable.obj, root,
                   @"OCSquirrelRootTable obj should be equal to the Squirrel VM's root table by default");
}


- (void) testThrowsIfInitWithHSQOBJECT
{
    HSQOBJECT object;
    sq_resetobject(&object);
    
    id root = nil;
    
    STAssertThrowsSpecificNamed(root = [[OCSquirrelRootTable alloc] initWithHSQOBJECT: object
                                                                                 inVM: _squirrelVM],
                                NSException, NSGenericException,
                                @"OCSquirrelRootTable should throw an exception if trying to initialize "
                                @"it with an existing HSQOBJECT. This operation does not make sense for "
                                @"HSQOBJECTs which are not the root table of the Squirrel VM, and if "
                                @"passing the actual root table then it is just redundant.");
}

@end
