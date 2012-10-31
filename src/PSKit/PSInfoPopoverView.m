//
//  PSInfoPopoverView.m
//  PSKit
//
//  Created by Peter Shih on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSInfoPopoverView.h"

@interface PSInfoPopoverView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIImageView *bubbleView;
@property (nonatomic, strong) UILabel *messageLabel;

@end

@implementation PSInfoPopoverView

- (id)initWithMessage:(NSString *)message {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.overlayView = [[UIView alloc] initWithFrame:CGRectZero];
        self.overlayView.autoresizingMask = ~UIViewAutoresizingNone;
        self.overlayView.backgroundColor = [UIColor blackColor];
        self.overlayView.alpha = 0.5;
        self.overlayView.userInteractionEnabled = YES;
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        gr.delegate = self;
        [self.overlayView addGestureRecognizer:gr];
        [self addSubview:self.overlayView];
        
        self.bubbleView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"InfoPopover"] stretchableImageWithLeftCapWidth:0 topCapHeight:100]];
        self.bubbleView.autoresizingMask = ~UIViewAutoresizingNone;
        [self addSubview:self.bubbleView];
        
//        UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"InfoPopover"]];
//        bg.autoresizingMask = ~UIViewAutoresizingNone;
//        bg.center = self.center;
//        bg.top = 44.0;
//        bg.height = 260;
//        [self addSubview:bg];
        
        self.messageLabel = [UILabel labelWithStyle:@"h5DarkLabel"];
        self.messageLabel.textAlignment = UITextAlignmentCenter;
        self.messageLabel.text = message;
        [self.bubbleView addSubview:self.messageLabel];
        
//        UILabel *infoLabel = [UILabel labelWithStyle:@"h6GeorgiaDarkLabel"];
//        infoLabel.text = @"Tap here to search!\r\n\r\nPinch and zoom the map to search for places in the desired area.\r\n\r\nYou can also enter any search keyword, like Pizza or Burgers.";
//        infoLabel.frame = UIEdgeInsetsInsetRect(bg.bounds, UIEdgeInsetsMake(30, 30, 42, 30));
//        [bg addSubview:infoLabel];
        
    }
    return self;
}

- (void)showInView:(UIView *)view {
    self.frame = view.bounds;
    self.overlayView.frame = self.bounds;

    self.bubbleView.width = 320.0;
    CGFloat width = self.bubbleView.width - 60.0;
    CGSize labelSize = [self.messageLabel sizeForLabelInWidth:width];
    self.bubbleView.height = 110.0 + labelSize.height;
    self.messageLabel.frame = UIEdgeInsetsInsetRect(self.bubbleView.bounds, UIEdgeInsetsMake(50, 30, 60, 30));
    self.bubbleView.center = self.center;
    self.bubbleView.top = 44.0;
    
    
    [view addSubview:self];
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


@end
