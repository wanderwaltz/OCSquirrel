//
//  TestOCSquirrelRootTable.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 21.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <OCSquirrel/OCSquirrel.h>


#pragma mark -
#pragma mark TestOCSquirrelRootTable interface

@interface TestOCSquirrelRootTable : SenTestCase
{
    OCSquirrelVM *_squirrelVM;
    OCSquirrelRootTable *_rootTable;
}

@end
