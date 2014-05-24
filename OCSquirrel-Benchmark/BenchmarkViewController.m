//
//  BenchmarkViewController.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 03.05.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "BenchmarkViewController.h"
#import <QuartzCore/QuartzCore.h>



#pragma mark -
#pragma mark BenchmarkViewController private

@interface BenchmarkViewController()
{
@private
    NSDate *_recordedDate;
}
@end



#pragma mark -
#pragma mark BenchmarkViewController implementation

@implementation BenchmarkViewController

#pragma mark -
#pragma mark initialization methods

- (id) init
{
    return [self initWithNibName: @"BenchmarkViewController"
                          bundle: nil];
}


- (id) initWithNibName: (NSString *) nibNameOrNil
                bundle: (NSBundle *) nibBundleOrNil
{
    self = [super initWithNibName: nibNameOrNil
                           bundle: nibBundleOrNil];
    
    if (self != nil)
    {
        _squirrelVM = [[OCSquirrelVM alloc] initWithStackSize: 20480];
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    return self;
}


#pragma mark -
#pragma mark view lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];

    self.logTextView.text = @"";
    
    self.logTextView.layer.borderColor  = [UIColor lightGrayColor].CGColor;
    self.logTextView.layer.borderWidth  = 1.0;
    self.logTextView.layer.cornerRadius = 4.0;
}

#pragma mark -
#pragma mark methods

- (IBAction) startBenchmark: (id) sender
{
    // Do nothing by default, override in subclasses.
}


- (void) log: (NSString *) string
{
    self.logTextView.text = [self.logTextView.text stringByAppendingFormat: @"\n%@", string];
    [self.logTextView scrollRangeToVisible: NSMakeRange(self.logTextView.text.length-1, 1)];
    
    [[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.25]];
}


- (void) recordDate
{
    _recordedDate = [NSDate date];
}


- (NSTimeInterval) intervalSinceLastRecord
{
    return [[NSDate date] timeIntervalSinceDate: _recordedDate];
}


@end
