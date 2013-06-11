//
//  TestOCSquirrelArray.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 6/10/13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#ifndef GHUnit_Target
    #import <SenTestingKit/SenTestingKit.h>
#endif

#import <OCSquirrel/OCSquirrel.h>


#pragma mark -
#pragma mark TestOCSquirrelArray interface

@interface TestOCSquirrelArray : SenTestCase
{
    OCSquirrelVM *_squirrelVM;
}

@end
