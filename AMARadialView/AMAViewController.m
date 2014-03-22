//
//  AMAViewController.m
//  AMARadialView
//
//  Created by Andreas Mächler on 06.02.14.
//  Copyright (c) 2014 Andreas Maechler. All rights reserved.
//

#import "AMAViewController.h"
#import "MDRadialProgressView.h"
#import "MDRadialProgressTheme.h"
#import "MDRadialProgressLabel.h"

#import "AMARadialView.h"

@interface AMAViewController ()

@property (weak, nonatomic) IBOutlet MDRadialProgressView *progressView;
@property (weak, nonatomic) IBOutlet AMARadialView *radialView;

@property (strong, nonatomic) NSTimer *progressTimer;
@property (strong, nonatomic) NSTimer *radialTimer;

@property (assign, nonatomic) BOOL radialDirectionCW;

@end

@implementation AMAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup the progress view
	self.progressView.progressTotal = 5;
    self.progressView.progressCounter = 1;
	self.progressView.clockwise = YES;

	self.progressView.theme.completedColor = [UIColor colorWithRed:90/255.0 green:200/255.0 blue:251/255.0 alpha:1.0];
	self.progressView.theme.incompletedColor = [UIColor colorWithRed:82/255.0 green:237/255.0 blue:199/255.0 alpha:1.0];

    self.progressView.theme.sliceDividerHidden = NO;
    self.progressView.theme.sliceDividerColor = [UIColor whiteColor];
	self.progressView.label.hidden = YES;

    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 / self.progressView.progressTotal
                                                  target:self
                                                selector:@selector(updateProgress)
                                                userInfo:nil
                                                 repeats:YES];
    
    // Setup the radial view
    self.radialDirectionCW = YES;
    
    self.radialView.offsetTotal = 200;
    self.radialView.offsetCurrent = 0;
    self.radialTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 / self.radialView.offsetTotal
                                                          target:self
                                                        selector:@selector(updateRadial)
                                                        userInfo:nil
                                                         repeats:YES];
    
}

- (void)dealloc
{
    [self.progressTimer invalidate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Timer callbacks

- (void)updateProgress
{
    self.progressView.progressCounter++;
    
    if (self.progressView.progressCounter == self.progressView.progressTotal) {
        self.progressView.clockwise = !self.progressView.clockwise;
        self.progressView.progressCounter = 0;
    }
}

- (void)updateRadial
{
    if (self.radialDirectionCW) {
        self.radialView.offsetCurrent++;
    } else {
        self.radialView.offsetCurrent--;
    }
    
    if (self.radialView.offsetCurrent >= self.radialView.offsetTotal ||
        self.radialView.offsetCurrent <= -(int)self.radialView.offsetTotal) {
        self.radialDirectionCW = !self.radialDirectionCW;
    }
}


@end
