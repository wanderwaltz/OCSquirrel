//
//  TestBindClass.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 4/26/13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#ifndef GHUnit_Target
    #import <XCTest/XCTest.h>
#endif

#import <OCSquirrel/OCSquirrel.h>
#import "BindingHelperClasses.h"


#pragma mark -
#pragma mark TestBindClass interface

@interface TestBindClass : XCTestCase
{
    OCSquirrelVM *_squirrelVM;
    OCSquirrelTable *_rootTable;
}

@end
