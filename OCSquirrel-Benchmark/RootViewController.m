//
//  RootViewController.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 03.05.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "RootViewController.h"
#import "StackPushBenchmark.h"
#import "StackSumBenchmark.h"


#pragma mark -
#pragma mark RootViewController implementation

@implementation RootViewController

#pragma mark -
#pragma mark initialization methods

- (id) initWithNibName: (NSString *) nibNameOrNil
                bundle: (NSBundle *) nibBundleOrNil
{
    self = [super initWithNibName: nibNameOrNil
                           bundle: nibBundleOrNil];
    
    if (self != nil)
    {
        self.title = @"OCSquirrel Benchmark";
        self.navigationItem.backBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle: @"Back"
                                         style: UIBarButtonItemStyleBordered
                                        target: nil
                                        action: nil];
    }
    return self;
}


#pragma mark -
#pragma mark actions

- (IBAction) stackPushBenchmark: (id) sender
{
    [self.navigationController pushViewController: [StackPushBenchmark new] animated: YES];
}


- (IBAction) stackSumBenchmark: (id) sender
{
    [self.navigationController pushViewController: [StackSumBenchmark new] animated: YES];
}

@end
