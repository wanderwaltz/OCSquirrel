//
//  TestBindClass.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 4/26/13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#ifndef GHUnit_Target
    #import <SenTestingKit/SenTestingKit.h>
#endif

#import <OCSquirrel/OCSquirrel.h>


#pragma mark -
#pragma mark TestBindClass interface

@interface TestBindClass : SenTestCase
{
    OCSquirrelVM *_squirrelVM;
}

@end
