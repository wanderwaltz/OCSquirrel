//
//  TestOCSquirrelInstance.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 04.05.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#ifndef GHUnit_Target
#import <XCTest/XCTest.h>
#endif

#import <OCSquirrel/OCSquirrel.h>


#pragma mark -
#pragma mark TestOCSquirrelInstance interface

@interface TestOCSquirrelInstance : XCTestCase
{
    OCSquirrelVM *_squirrelVM;
    OCSquirrelInstance *_instance;
}

@end
