//
//  AppDelegate.m
//  OCSquirrel-Benchmark
//
//  Created by Egor Chiglintsev on 03.05.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "AppDelegate.h"
#import "RootViewController.h"


#pragma mark -
#pragma mark AppDelegate implementation

@implementation AppDelegate

- (BOOL)          application: (UIApplication *) application
didFinishLaunchingWithOptions: (NSDictionary  *) launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    
    RootViewController *controller = [RootViewController new];
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController: controller];
    
    
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
