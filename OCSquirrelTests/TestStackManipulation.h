//
//  TestStackManipulation.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 14.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCSquirrel/OCSquirrel.h>


#pragma mark -
#pragma mark TestStackManipulation interface

@interface TestStackManipulation : XCTestCase
{
    OCSquirrelVM *_squirrelVM;
}

@end
