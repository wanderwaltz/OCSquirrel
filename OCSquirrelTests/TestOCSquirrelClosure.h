//
//  TestOCSquirrelClosure.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 27.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#ifndef GHUnit_Target
    #import <XCTest/XCTest.h>
#endif

#import <OCSquirrel/OCSquirrel.h>


#pragma mark -
#pragma mark TestOCSquirrelClosure interface

@interface TestOCSquirrelClosure : XCTestCase
{
    OCSquirrelVM *_squirrelVM;
    OCSquirrelTable *_root;
    BOOL _closureCalled;
}

@end
