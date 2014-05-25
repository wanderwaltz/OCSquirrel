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

#ifndef GHUnit_Target
#import <XCTest/XCTest.h>
#endif

#import <OCSquirrel/OCSquirrel.h>
#import "OCMock.h"


#pragma mark -
#pragma mark OCSquirrelPrintDelegate interface

/*! A class which is used for testing that delegate method is invoked by OCSquirrelVM when
 a script tries to print some string. Actual implementation of the delegate method is not
 important since the method invocation will be tested by an OCMockObject. The OCMockObject
 cannot mock -respondsToSelector:, so this class is needed only for that.
 
 See -testPrintCallsDelegateMethod below for more info.
 */
@interface OCSquirrelPrintDelegate : NSObject<OCSquirrelVMDelegate>
@end


#pragma mark -
#pragma mark TestPrinting interface

@interface TestPrinting : XCTestCase<OCSquirrelVMDelegate>
{
    OCSquirrelVM *_squirrelVM;
    NSString *_lastPrintedString;
}

@end


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


#pragma mark -
#pragma mark basic tests

- (void) testPrintCallsDelegateMethod
{
    id delegate = [OCMockObject partialMockForObject: [OCSquirrelPrintDelegate new]];
    
    _squirrelVM.delegate = delegate;
    
    NSString * const kHelloWorld = @"Hello, World!";
    
    [[delegate expect] squirrelVM: _squirrelVM didPrintString: kHelloWorld];
    
    NSString *printHelloWorld = [NSString stringWithFormat: @"print(\"%@\");", kHelloWorld];
    
    [_squirrelVM execute: printHelloWorld error: nil];
    
    XCTAssertNoThrow([delegate verify],
                    @"Delegate method -squirrelVM:didPrintString: should be invoked with the OCSquirrelVM "
                    @"instance which compiled the script and the string which was passed to print function.");
}


- (void) testPrintEnglishUnchanged
{
    static NSString * const kEnglishString = @"abcdefghijklmnopqrtsuvwxyz";
    
    NSString *printEnglishString = [NSString stringWithFormat: @"print(\"%@\");", kEnglishString];
    
    [_squirrelVM execute: printEnglishString error: nil];
    
    XCTAssertEqualObjects(_lastPrintedString, kEnglishString,
                         @"String containing only letters from English alphabet should be "
                         @"printed to an NSString from a Squirrel script unchanged.");
}


- (void) testPrintUnicodeUnchanged
{
    // The string contains the word 'unicode' in Russian
    static NSString * const kUnicodeString = @"юникод";
    
    NSString *printUnicodeString = [NSString stringWithFormat: @"print(\"%@\");", kUnicodeString];
    
    [_squirrelVM execute: printUnicodeString error: nil];
    
    XCTAssertEqualObjects(_lastPrintedString, kUnicodeString,
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
