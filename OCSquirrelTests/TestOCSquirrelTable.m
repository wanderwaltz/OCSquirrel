//
//  TestOCSquirrelTable.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 26.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#ifndef GHUnit_Target
    #import <XCTest/XCTest.h>
#endif

#import <OCSquirrel/OCSquirrel.h>

@interface TestOCSquirrelTable : XCTestCase
{
    OCSquirrelVM *_squirrelVM;   
}
@end

@implementation TestOCSquirrelTable

- (void) setUp
{
    [super setUp];
    _squirrelVM = [[OCSquirrelVM alloc] init];
}


- (void) tearDown
{
    _squirrelVM = nil;
    [super tearDown];
}


#pragma mark - NSMutableDictionary integration tests

- (void)testKindOfDictionary
{
    OCSquirrelTable *table = [OCSquirrelTable new];
    
    XCTAssertTrue([table isKindOfClass: [NSDictionary class]],
                  @"OCSquirrelTable should be kind of NSDictionary");
}


- (void)testKindOfMutableDictionary
{
    OCSquirrelTable *table = [OCSquirrelTable new];
    
    XCTAssertTrue([table isKindOfClass: [NSMutableDictionary class]],
                  @"OCSquirrelTable should be kind of NSMutableDictionary");
}



@end
