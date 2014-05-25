//
//  StackSumBenchmark.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 03.05.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "StackSumBenchmark.h"


#pragma mark -
#pragma mark StackSumBenchmark implementation

@implementation StackSumBenchmark

#pragma mark -
#pragma mark initialization methods

- (id) initWithNibName: (NSString *) nibNameOrNil
                bundle: (NSBundle *) nibBundleOrNil
{
    self = [super initWithNibName: nibNameOrNil
                           bundle: nibBundleOrNil];
    
    if (self != nil)
    {
        self.title = @"Stack Sum";
    }
    return self;
}


#pragma mark -
#pragma mark view lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.descriptionLabel.text = @"Sum of a large number of values from the Squirrel VM stack.";
}


#pragma mark -
#pragma mark methods

- (void) startBenchmark: (id) sender
{
    static const NSUInteger iterations = 10000;
    
    [self log: @"Starting benchmark..."];
    
    
    // Pushing integers using C API
    [self log:
     [NSString stringWithFormat: @"Pushing %lu integers to the stack using C API...", (unsigned long)iterations]];
    
    self.squirrelVM.stack.top = 0;
    [self recordDate];
    
    for (NSUInteger i = 0; i < iterations; ++i)
    {
        sq_pushinteger(self.squirrelVM.vm, i);
    }
    
    [self log:
     [NSString stringWithFormat: @"Finished in %.3lf seconds.", [self intervalSinceLastRecord]]];
    
    
    NSUInteger sum   = 0;
    SQInteger  value = 0;
    
    // Summing integers using C API
    [self log:
     [NSString stringWithFormat: @"Summing %lu integers from the stack using C API...", (unsigned long)iterations]];
    
    [self recordDate];
    
    for (NSUInteger i = 0; i < iterations; ++i)
    {
        sq_getinteger(self.squirrelVM.vm, i+1, &value);
        sum += value;
    }
    
    [self log:
     [NSString stringWithFormat: @"Finished in %.3lf seconds with sum: %lu.",
      [self intervalSinceLastRecord], (unsigned long)sum]];

    
    sum = 0;
    
    // Summing integers using OCSquirrelVM
    [self log:
     [NSString stringWithFormat: @"Summing %lu integers from the stack using OCSquirrelVM.", (unsigned long)iterations]];
    
    [self recordDate];
    
    for (NSUInteger i = 0; i < iterations; ++i)
    {
        sum += [self.squirrelVM.stack integerAtPosition: i+1];
    }
    
    [self log:
     [NSString stringWithFormat: @"Finished in %.3lf seconds with sum: %lu.",
      [self intervalSinceLastRecord], (unsigned long)sum]];

    
    sum = 0;
    
    // Summing integers using OCSquirrelVM (NSNumber)
    [self log:
     [NSString stringWithFormat: @"Summing %lu NSNumber integers from the stack using OCSquirrelVM.", (unsigned long)iterations]];
    
    [self recordDate];
    
    for (NSUInteger i = 0; i < iterations; ++i)
    {
        sum += [[self.squirrelVM.stack valueAtPosition: i+1] integerValue];
    }
    
    [self log:
     [NSString stringWithFormat: @"Finished in %.3lf seconds with sum: %lu.",
      [self intervalSinceLastRecord], (unsigned long)sum]];
    
    
    self.squirrelVM.stack.top = 0;
}

@end
