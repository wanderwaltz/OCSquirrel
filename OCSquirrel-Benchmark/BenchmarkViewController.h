//
//  BenchmarkViewController.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 03.05.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OCSquirrel/OCSquirrel.h>

#pragma mark -
#pragma mark BenchmarkViewController interface

@interface BenchmarkViewController : UIViewController
@property (readonly, nonatomic) OCSquirrelVM *squirrelVM;

@property (weak, nonatomic) IBOutlet UILabel    *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton   *startButton;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;

- (IBAction) startBenchmark: (id) sender;

- (void) log: (NSString *) string;

- (void) recordDate;
- (NSTimeInterval) intervalSinceLastRecord;

@end
