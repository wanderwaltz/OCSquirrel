//
//  TestOCSquirrelArray.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 6/10/13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#ifndef GHUnit_Target
    #import <XCTest/XCTest.h>
#endif

#import <OCSquirrel/OCSquirrel.h>


#pragma mark -
#pragma mark TestOCSquirrelArray interface

@interface TestOCSquirrelArray : XCTestCase
{
    OCSquirrelVM *_squirrelVM;
}

@end
