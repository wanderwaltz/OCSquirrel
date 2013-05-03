//
//  TestOCSquirrelTable.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 14.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#ifndef GHUnit_Target
    #import <SenTestingKit/SenTestingKit.h>
#endif

#import <OCSquirrel/OCSquirrel.h>


#pragma mark -
#pragma mark TestOCSquirrelTable interface

@interface TestOCSquirrelTable : SenTestCase
{
    OCSquirrelVM *_squirrelVM;
}

@end
