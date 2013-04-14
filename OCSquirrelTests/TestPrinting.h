//
//  TestPrinting.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 14.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <OCSquirrel/OCSquirrel.h>


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

@interface TestPrinting : SenTestCase<OCSquirrelVMDelegate>
{
    OCSquirrelVM *_squirrelVM;
    NSString *_lastPrintedString;
}

@end
