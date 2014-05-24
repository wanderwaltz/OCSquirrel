//
//  TestOCSquirrelClass.h
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
#pragma mark TestOCSquirrelClass interface

@interface TestOCSquirrelClass : XCTestCase
{
    OCSquirrelVM *_squirrelVM;
    OCSquirrelClass *_class;
}

@end
