//
//  ViewController.h
//  CoreAnimation
//
//  Created by 将司 小野 on 12/04/14.
//  Copyright (c) 2012年 AppBankGames Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnimationButton.h"

@interface ViewController : UIViewController

@property (nonatomic, retain) IBOutlet AnimationButtonView *animationView;

- (IBAction)onButtonTapped:(id)sender;

@end
