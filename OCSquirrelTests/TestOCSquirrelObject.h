//
//  TestOCSquirrelObject.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 14.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <OCSquirrel/OCSquirrel.h>


#pragma mark -
#pragma mark TestOCSquirrelObject interface

@interface TestOCSquirrelObject : SenTestCase
{
    OCSquirrelVM *_squirrelVM;
}

@end
