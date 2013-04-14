//
//  TestPrinting.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 14.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "TestPrinting.h"
#import "OCMock.h"


#pragma mark -
#pragma mark OCSquirrelPrintDelegate implementation

@implementation OCSquirrelPrintDelegate

- (void) squirrelVM: (OCSquirrelVM *) squirrelVM didPrintString: (NSString *) string {}

@end


#pragma mark -
#pragma mark TestPrinting implementation

@implementation TestPrinting

- (void) setUp
{
    [super setUp];
    _squirrelVM          = [[OCSquirrelVM alloc] init];
    _squirrelVM.delegate = self;
}


- (void) tearDown
{
    _squirrelVM = nil;
    [super tearDown];
}


- (void) testPrintCallsDelegateMethod
{
    id delegate = [OCMockObject partialMockForObject: [OCSquirrelPrintDelegate new]];
    
    _squirrelVM.delegate = delegate;
    
    NSString * const kHelloWorld = @"Hello, World!";
    
    [[delegate expect] squirrelVM: _squirrelVM didPrintString: kHelloWorld];
    
    NSString *printHelloWorld = [NSString stringWithFormat: @"print(\"%@\");", kHelloWorld];
    
    [_squirrelVM executeSync: printHelloWorld];
    
    STAssertNoThrow([delegate verify],
                    @"Delegate method -squirrelVM:didPrintString: should be invoked with the OCSquirrelVM "
                    @"instance which compiled the script and the string which was passed to print function.");
    [NSThread sleepForTimeInterval:1.0];
}


- (void) testPrintEnglishUnchanged
{
    static NSString * const kEnglishString = @"abcdefghijklmnopqrtsuvwxyz";
    
    NSString *printEnglishString = [NSString stringWithFormat: @"print(\"%@\");", kEnglishString];
    
    [_squirrelVM executeSync: printEnglishString];
    
    STAssertEqualObjects(_lastPrintedString, kEnglishString,
                         @"String containing only letters from English alphabet should be "
                         @"printed to an NSString from a Squirrel script unchanged.");
}


- (void) testPrintUnicodeUnchanged
{
    // The string contains the word 'unicode' in Russian
    static NSString * const kUnicodeString = @"юникод";
    
    NSString *printUnicodeString = [NSString stringWithFormat: @"print(\"%@\");", kUnicodeString];
    
    [_squirrelVM executeSync: printUnicodeString];
    
    STAssertEqualObjects(_lastPrintedString, kUnicodeString,
                         @"String containing unicode characters should be "
                         @"printed to an NSString from a Squirrel script unchanged.");
}


#pragma mark -
#pragma mark OCSquirrelVMDelegate

- (void) squirrelVM: (OCSquirrelVM *) squirrelVM didPrintString: (NSString *) string
{
    _lastPrintedString = string;
}

@end
