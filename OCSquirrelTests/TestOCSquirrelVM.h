//
//  TestOCSquirrelVM.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 13.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCSquirrel/OCSquirrel.h>

#pragma mark -
#pragma mark TestOCSquirrelVM interface

@interface TestOCSquirrelVM : XCTestCase
{
    OCSquirrelVM *_squirrelVM;
}

@end
