//
//  ViewController.m
//  CoreAnimation
//
//  Created by 将司 小野 on 12/04/14.
//  Copyright (c) 2012年 AppBankGames Inc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize button = _button;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.button.frame = CGRectMake(0, 0, 100.0f, 44.0f);
    self.button.center = self.view.center;
    [self.button setTitle:@"Tap me" forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(onButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
}

- (void)viewDidUnload
{
    self.button = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (IBAction)onButtonTapped:(id)sender
{
    CGFloat x = (CGFloat)(arc4random() % (NSInteger)(CGRectGetWidth(self.view.bounds)-CGRectGetWidth(self.button.frame)));
    CGFloat y = (CGFloat)(arc4random() % (NSInteger)(CGRectGetHeight(self.view.bounds)-CGRectGetHeight(self.button.frame)));
    self.button.frame = CGRectMake(x,
                                   y,
                                   CGRectGetWidth(self.button.frame),
                                   CGRectGetHeight(self.button.frame));
}

@end
