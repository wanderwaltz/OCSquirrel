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
    OCSquirrelClass *class = [_squirrelVM bindClass: [NSDate class]];
    
    STAssertNotNil(class,
                   @"bindClass should return an OCSquirrelClass instance");
}


- (void) testBindingTwiceSameClass
{
    OCSquirrelClass *class1 = [_squirrelVM bindClass: [NSDate class]];
    OCSquirrelClass *class2 = [_squirrelVM bindClass: [NSDate class]];
    
    STAssertEqualObjects(class1, class2,
                         @"bindClass should return the same OCSquirrelClass "
                         @"for the same Objective-C classes");
}


- (void) testType
{
    OCSquirrelClass *class = [_squirrelVM bindClass: [NSDate class]];
    
    STAssertEquals(class.type, OT_CLASS,
                   @"bindClass should return an OCSquirrelObject of type OT_CLASS");
}


@end
