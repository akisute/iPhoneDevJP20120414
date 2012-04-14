//
//  ViewController.m
//  CoreAnimation
//
//  Created by 将司 小野 on 12/04/14.
//  Copyright (c) 2012年 AppBankGames Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"


@implementation ViewController

@synthesize animationView = _animationView;
@synthesize apiClient = _apiClient;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.animationView = [[[AnimationButtonView alloc] initWithFrame:CGRectMake(0, 0, 100.0f, 44.0f)] autorelease];
    self.animationView.center = self.view.center;
    [self.animationView.button setTitle:@"Tap me" forState:UIControlStateNormal];
    [self.animationView.button addTarget:self action:@selector(onButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    //[self.animationView.button addTarget:self action:@selector(onButtonTappedForAPI:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.animationView];
    
    self.apiClient = [[[APIClient alloc] init] autorelease];
}

- (void)viewDidUnload
{
    self.animationView = nil;
    self.apiClient = nil;
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


#pragma mark - IBAction


- (IBAction)onButtonTapped:(id)sender
{
    // 移動先の点とか計算するよ
    CGFloat x = (CGFloat)(arc4random() % (NSInteger)CGRectGetWidth(self.view.bounds));
    CGFloat y = (CGFloat)(arc4random() % (NSInteger)CGRectGetHeight(self.view.bounds));
    CGPoint p = CGPointMake(x, y);
    
    // キーフレームアニメーションを作るよ
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    animation.values = [NSArray arrayWithObjects:
                        [NSValue valueWithCGPoint:self.animationView.layer.position],
                        [NSValue valueWithCGPoint:self.view.center],
                        [NSValue valueWithCGPoint:p],
                        nil];
    animation.keyTimes = [NSArray arrayWithObjects:
                          [NSNumber numberWithFloat:0.0f],
                          [NSNumber numberWithFloat:0.5f],
                          [NSNumber numberWithFloat:1.0f],
                          nil];
    animation.timingFunctions = [NSArray arrayWithObjects:
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                                 nil];
    animation.calculationMode = kCAAnimationLinear;
    animation.duration = 0.5;
    animation.delegate = self;
    
    // CAAnimation, CALayerなんかは任意の値をKVOでセットできる性質があるよ
    // なんとかいう名前で呼ぶらしいんだけど忘れた＞＜
    [animation setValue:[NSValue valueWithCGPoint:p] forKey:@"MyCustomValueKey"];
    
    // 作ったアニメーションをアクションとしてレイヤーに与えてやるよ
    self.animationView.layer.actions = [NSDictionary dictionaryWithObject:animation forKey:@"position"];
    
    // じゃあ早速目標地点に対して移動しつつアニメーションしてもらおうか！
    self.animationView.layer.position = p;
}

- (IBAction)onButtonTappedForAPI:(id)sender
{
    [self.apiClient api_google:nil callback:^(APIClientResponse *response) {
        //NSLog(@"response = %@", response);
        NSLog(@"response = %@ sender = %@", response, sender);
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        for (NSUInteger i=0; i<1000; i++) {
            NSLog(@"abesi");
        }
    });
}


#pragma mark - CAAnimationDelegate


- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    // さっきアニメーションにKVOで突っ込んだ値を取り出すよっと
    NSValue *value = [theAnimation valueForKey:@"MyCustomValueKey"];
    CGPoint p = [value CGPointValue];
    [self.animationView.button setTitle:NSStringFromCGPoint(p) forState:UIControlStateNormal];
}

@end
