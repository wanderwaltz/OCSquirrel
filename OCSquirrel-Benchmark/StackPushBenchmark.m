//
//  StackPushBenchmark.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 03.05.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "StackPushBenchmark.h"



#pragma mark -
#pragma mark StackPushBenchmark implementation

@implementation StackPushBenchmark

#pragma mark -
#pragma mark initialization methods

- (id) initWithNibName: (NSString *) nibNameOrNil
                bundle: (NSBundle *) nibBundleOrNil
{
    self = [super initWithNibName: nibNameOrNil
                           bundle: nibBundleOrNil];
    
    if (self != nil)
    {
        self.title = @"Stack Push";
    }
    return self;
}


#pragma mark -
#pragma mark view lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.descriptionLabel.text = @"This benchmark tests the basic stack push operation via C API and "
                                @"using OCSquirrelVM";
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
        [self.squirrelVM perform:^(HSQUIRRELVM vm, id<OCSquirrelVMStack> stack) {
            sq_pushinteger(vm, i); 
        }];
    }
    
    [self log:
     [NSString stringWithFormat: @"Finished in %.3lf seconds.", [self intervalSinceLastRecord]]];

    // Pushing integers using OCSquirrelVM
    [self log:
     [NSString stringWithFormat: @"Pushing %lu integers to the stack using OCSquirrelVM...", (unsigned long)iterations]];
    
    self.squirrelVM.stack.top = 0;
    [self recordDate];

    for (NSUInteger i = 0; i < iterations; ++i)
    {
        [self.squirrelVM.stack pushInteger: i];
    }

    [self log:
     [NSString stringWithFormat: @"Finished in %.3lf seconds.", [self intervalSinceLastRecord]]];
    
    
    
    // Pushing integers using OCSquirrelVM (NSNumber)
    [self log:
     [NSString stringWithFormat: @"Pushing %lu NSNumber integers to the stack using OCSquirrelVM...", (unsigned long)iterations]];
    
    self.squirrelVM.stack.top = 0;
    [self recordDate];
    
    for (NSUInteger i = 0; i < iterations; ++i)
    {
        [self.squirrelVM.stack pushValue: @(i)];
    }
    
    [self log:
     [NSString stringWithFormat: @"Finished in %.3lf seconds.", [self intervalSinceLastRecord]]];
    
    
    
    self.squirrelVM.stack.top = 0;
}

@end
