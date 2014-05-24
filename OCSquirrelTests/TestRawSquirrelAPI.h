//
//  TestRawSquirrelAPI.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 13.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#ifndef GHUnit_Target
    #import <XCTest/XCTest.h>
#endif

#import <OCSquirrel/OCSquirrel.h>

#pragma mark -
#pragma mark TestRawSquirrelAPI

/*! General Squirrel API tests will be included here. Obviously testing the Squirrel itself completely is somewhat out of scope of this project, but to some extent it may be useful to test parts of the Squirrel functionality which are actually used by the OCSquirrel.
 */
@interface TestRawSquirrelAPI : XCTestCase
{
    HSQUIRRELVM _vm;
}

@end
