//
//  PSPopoverView.m
//  Phototime
//
//  Created by Peter on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSPopoverView.h"

#define MARGIN 8.0

@interface PSPopoverView ()

@property (nonatomic, strong) UIViewController *containerController;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *arrowView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, assign) CGSize popoverSize;

- (void)positionPopover;

@end

@implementation PSPopoverView

@synthesize
containerController = _containerController,
containerView = _containerView,
arrowView = _arrowView,
titleLabel = _titleLabel,
popoverSize = _popoverSize,
overlayView = _overlayView,
contentView = _contentView,
delegate = _delegate;

- (id)initWithTitle:(NSString *)title contentController:(UIViewController *)contentController {
    self = [self initWithTitle:title contentView:contentController.view];
    if (self) {
        self.containerController = contentController;
    }
    return self;
}

- (id)initWithTitle:(NSString *)title contentView:(UIView *)contentView {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.popoverSize = CGSizeZero;
        
        self.overlayView = [[UIView alloc] initWithFrame:CGRectZero];
        self.overlayView.backgroundColor = [UIColor blackColor];
        self.overlayView.alpha = 0.5;
        self.overlayView.userInteractionEnabled = YES;
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        gr.delegate = self;
        [self.overlayView addGestureRecognizer:gr];
        [self addSubview:self.overlayView];
        
        // Container
        self.containerView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.containerView];
        
        UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"PSKit.bundle/PopoverPortrait"] stretchableImageWithLeftCapWidth:152 topCapHeight:170]];
        bgImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        bgImageView.frame = self.containerView.bounds;
        [self.containerView addSubview:bgImageView];
        
        self.titleLabel = [UILabel labelWithText:title style:@"popoverTitleLabel"];
        [self.containerView addSubview:self.titleLabel];

        // ContentView
        self.contentView = contentView;
        self.contentView.layer.cornerRadius = 4.0;
        self.contentView.layer.masksToBounds = YES;
        [self.containerView addSubview:self.contentView];
        
        
        // Arrow
        self.arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PSKit.bundle/PopoverPortraitArrowUp"]];
        [self addSubview:self.arrowView];
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.overlayView.frame = self.bounds;
    
    // Container
    CGSize containerSize = CGSizeMake(self.popoverSize.width + MARGIN * 2, self.popoverSize.height + MARGIN * 3 + 24);
    
    self.containerView.width = containerSize.width;
    self.containerView.height = containerSize.height;
    self.containerView.center = self.center;
    self.containerView.top = 52.0;
    
    self.titleLabel.frame = CGRectMake(MARGIN, MARGIN, self.containerView.width - MARGIN * 2, 24.0);
    
    self.contentView.frame = CGRectMake(MARGIN, MARGIN, self.popoverSize.width, self.popoverSize.height);
    self.contentView.top = self.titleLabel.bottom + MARGIN;
    
    self.arrowView.center = self.center;
    self.arrowView.top = self.containerView.top - self.arrowView.height + 3.0;
}

- (void)positionPopover {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

    CGRect orientationFrame = [UIScreen mainScreen].bounds;
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        CGFloat t = orientationFrame.size.width;
        orientationFrame.size.width = orientationFrame.size.height;
        orientationFrame.size.height = t;
        
        t = statusBarFrame.size.width;
        statusBarFrame.size.width = statusBarFrame.size.height;
        statusBarFrame.size.height = t;
    }
    
    CGFloat posY = orientationFrame.size.height / 2;
    CGFloat posX = orientationFrame.size.width / 2;
    
    CGFloat rotateAngle;
    CGPoint newCenter;
    
    switch (orientation) { 
        case UIInterfaceOrientationPortraitUpsideDown:
            rotateAngle = M_PI; 
            newCenter = CGPointMake(posX, orientationFrame.size.height-posY);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            rotateAngle = -M_PI/2.0f;
            newCenter = CGPointMake(posY, posX);
            break;
        case UIInterfaceOrientationLandscapeRight:
            rotateAngle = M_PI/2.0f;
            newCenter = CGPointMake(orientationFrame.size.height-posY, posX);
            break;
        default: // as UIInterfaceOrientationPortrait
            rotateAngle = 0.0;
            newCenter = CGPointMake(posX, posY);
            break;
    }
    
    self.transform = CGAffineTransformMakeRotation(rotateAngle);
    self.center = newCenter;
}

- (void)showWithSize:(CGSize)size inView:(UIView *)view {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    self.popoverSize = size;
    
    self.frame = view.bounds;
    [view addSubview:self];
    self.alpha = 0.0;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.alpha = 1.0;
    } completion:^(BOOL finished){
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

- (void)dismiss {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished){
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(popoverViewDidDismiss:)]) {
            [self.delegate popoverViewDidDismiss:self];
        }
        
        [self removeFromSuperview];
    }];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
  if ([touch.view isEqual:self.overlayView]) {
    return YES;
  } else {
    return NO;
  }
}

@end
