//
//  AnimationButton.m
//  iPhoneDevJP20120414
//
//  Created by 将司 小野 on 12/04/14.
//  Copyright (c) 2012年 AppBankGames Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AnimationButton.h"

@implementation AnimationButtonView


@synthesize button = _button;


#pragma mark - Init/dealloc


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.button.frame = self.bounds;
        [self addSubview:self.button];
    }
    return self;
}


#pragma mark - CALayerDelegate


- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)key
{
    // https://developer.apple.com/library/ios/#documentation/GraphicsImaging/Reference/CALayer_class/Introduction/Introduction.html # actionForKey: を参照
    // http://forums.pragprog.com/forums/57/topics/1392
    // 要するにUIViewがactionForLayer:forKey:デリゲートを実装しちゃってるのでself.layer.actionsが全く役に立っていない
    // そこでUIView側のactionForLayer:forKey:をオーバーライドしてしまってself.layer.actionの値を優先するようにすればうまくアニメーションが使えるというわけ
    id<CAAction> animation = [self.layer.actions objectForKey:key];
    if (animation) {
        return animation;
    } else {
        return [super actionForLayer:layer forKey:key];
    }
}

@end
