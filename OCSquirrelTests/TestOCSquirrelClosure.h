//
//  TestOCSquirrelClosure.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 27.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <OCSquirrel/OCSquirrel.h>


#pragma mark -
#pragma mark TestOCSquirrelClosure interface

@interface TestOCSquirrelClosure : SenTestCase
{
    OCSquirrelVM *_squirrelVM;
    OCSquirrelTable *_root;
    BOOL _closureCalled;
}

@end
