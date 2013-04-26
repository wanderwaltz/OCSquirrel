//
//  TestBindClass.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 4/26/13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "TestBindClass.h"


#pragma mark -
#pragma mark TestBindClass implementation

@implementation TestBindClass

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


- (void) testBindClassExists
{
    STAssertTrue([OCSquirrelVM instancesRespondToSelector: @selector(bindClass:)],
                 @"OCSquirrelVM should have a -bindClass: method");
}


- (void) testBindClassNoThrow
{
    STAssertNoThrow([_squirrelVM bindClass: [NSDate class]],
                    @"OCSquirrelVM should not throw exception when binding a class");
}


- (void) testDoesCreateSquirrelClass
{
    [_squirrelVM bindClass: [NSDate class]];
    id instance = [_squirrelVM executeSync: @"return NSDate();"];
    
    STAssertNotNil(instance,
                   @"After binding a class SquirrelVM should be able to create its intsnces.");
}

@end
