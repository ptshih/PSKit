//
//  PSZoomView.m
//  OSnap
//
//  Created by Peter Shih on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PSZoomView.h"

#define ZOOM_DURATION 0.2

@implementation PSZoomView

@synthesize
newFrame = _newFrame;

- (id)initWithImage:(UIImage *)image contentMode:(UIViewContentMode)contentMode {
    
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        
        // TODO: Get rid of status bar when zooming
        _shouldRotate = [image isLandscape];
        
        _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _backgroundView.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha = 0.0;
        [self addSubview:_backgroundView];
        
        _zoomedView = [[UIImageView alloc] initWithImage:image];
        // Adjust zoomview based on actual image size
//        CGFloat iWidth = image.size.width;
//        CGFloat iHeight = image.size.height;
        CGSize withinSize = self.bounds.size;
        CGFloat widthScale = withinSize.width / image.size.width;
        CGFloat heightScale = withinSize.height / image.size.height;
        CGFloat scale = MIN(widthScale, heightScale);
        self.newFrame = CGRectMake(0, 0, floorf(image.size.width * scale), floorf(image.size.height * scale));
        
        _zoomedView.frame = self.newFrame;
        _zoomedView.center = self.center;
        self.newFrame = _zoomedView.frame;
        _zoomedView.contentMode = contentMode;
        _zoomedView.clipsToBounds = YES;
        _zoomedView.userInteractionEnabled = YES;
        [self addSubview:_zoomedView];
        
        UITapGestureRecognizer *gr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)] autorelease];
        [_zoomedView addGestureRecognizer:gr];
        _zoomedView.alpha = 0.0;
    }
    return self;
}

- (void)dealloc {
    RELEASE_SAFELY(_backgroundView);
    RELEASE_SAFELY(_zoomedView);
    [super dealloc];
}

- (void)showInRect:(CGRect)rect {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    self.frame = [[UIScreen mainScreen] bounds];
    _backgroundView.frame = self.bounds;
    
    _originalRect = rect;
    _zoomedView.frame = _originalRect;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    [[APP_DELEGATE window] addSubview:self];
    _zoomedView.userInteractionEnabled = NO;
    [UIView animateWithDuration:ZOOM_DURATION delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        _zoomedView.alpha = 1.0;
        _backgroundView.alpha = 1.0;
    } completion:^(BOOL finished) {
        // Rotate/Zoom image if necessary
        [UIView animateWithDuration:ZOOM_DURATION delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            if (_shouldRotate) {
                CGSize withinSize = CGSizeMake(self.bounds.size.height, self.bounds.size.width);
                CGFloat widthScale = withinSize.width / self.newFrame.size.width;
                CGFloat heightScale = withinSize.height / self.newFrame.size.height;
                CGFloat scale = MIN(widthScale, heightScale);
                self.newFrame = CGRectMake(floorf((self.width - self.newFrame.size.width * scale) / 2), floorf((self.height - self.newFrame.size.height * scale) / 2), self.newFrame.size.width * scale, self.newFrame.size.height * scale);
                _zoomedView.frame = self.newFrame;
                _zoomedView.transform = CGAffineTransformMakeRotation(0.5 * M_PI);                
            } else {
                _zoomedView.frame = self.newFrame;
            }
        } completion:^(BOOL finished){
            _zoomedView.userInteractionEnabled = YES;
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }];
    }];
}

- (void)dismiss {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    _zoomedView.userInteractionEnabled = NO;
    [UIView animateWithDuration:ZOOM_DURATION delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        if (_shouldRotate) _zoomedView.transform = CGAffineTransformIdentity;
        _zoomedView.frame = _originalRect;
    } completion:^(BOOL finished){
        [UIView animateWithDuration:ZOOM_DURATION delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            _zoomedView.alpha = 0.0;
            _backgroundView.alpha = 0.0;
        } completion:^(BOOL finished){
            [self removeFromSuperview];
        }];
    }];
}

@end
