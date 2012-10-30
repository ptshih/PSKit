//
//  PSZoomView.m
//  OSnap
//
//  Created by Peter Shih on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PSZoomView.h"

#define ZOOM_DURATION 0.2

@interface PSZoomView ()

@property (nonatomic, weak) UIView *superView;
@property (nonatomic, weak) UIView *zoomedView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, assign) CGRect convertedFrame;
@property (nonatomic, assign) CGRect originalFrame;
@property (nonatomic, assign) MKCoordinateRegion oldMapRegion;
@property (nonatomic, assign) BOOL shouldRotate;
@property (nonatomic, assign) BOOL isZooming;

- (void)showView:(UIView *)view withFrame:(CGRect)frame inView:(UIView *)inView fullscreen:(BOOL)fullscreen;
- (void)dismiss:(UITapGestureRecognizer *)gr;

@end

@implementation PSZoomView

+ (id)sharedView {
    static id sharedView = nil;
    if (!sharedView) {
        sharedView = [[self alloc] initWithFrame:CGRectZero];
    }
    return sharedView;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.isZooming = NO;
        
        self.superView = nil;
        self.zoomedView = nil;
        
        self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundView.backgroundColor = [UIColor blackColor];
        self.backgroundView.alpha = 0.0;
        [self addSubview:self.backgroundView];
        
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
        [self addGestureRecognizer:gr];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reset) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

+ (BOOL)prepareToZoom {
    if ([[[self class] sharedView] isZooming]) {
        return NO;
    } else {
        [[[self class] sharedView] setIsZooming:YES];
        return YES;
    }
}

+ (void)showMapView:(MKMapView *)mapView withFrame:(CGRect)frame inView:(UIView *)inView fullscreen:(BOOL)fullscreen {
    [[[self class] sharedView] setOldMapRegion:mapView.region];
    mapView.scrollEnabled = YES;
    mapView.zoomEnabled = YES;
    [[[self class] sharedView] showView:mapView withFrame:frame inView:inView fullscreen:YES];
}

+ (void)showView:(UIView *)view withFrame:(CGRect)frame inView:(UIView *)inView fullscreen:(BOOL)fullscreen {
    [[[self class] sharedView] showView:view withFrame:frame inView:inView fullscreen:fullscreen];
}

+ (void)showImage:(UIImage *)image withFrame:(CGRect)frame inView:(UIView *)inView {
    PSImageView *iv = [[PSImageView alloc] initWithImage:[image copy]];
    [[[self class] sharedView] showView:iv withFrame:frame inView:inView fullscreen:NO];
}

- (void)showView:(UIView *)view withFrame:(CGRect)frame inView:(UIView *)inView fullscreen:(BOOL)fullscreen {
    self.zoomedView = view;
    self.convertedFrame = frame;
    self.originalFrame = view.frame;
    
    if (isDeviceIPad()) {
        CGFloat rotateAngle;
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        switch (orientation) {
            case UIInterfaceOrientationPortraitUpsideDown:
                rotateAngle = M_PI;
                break;
            case UIInterfaceOrientationLandscapeLeft:
                rotateAngle = -M_PI / 2.0f;
                break;
            case UIInterfaceOrientationLandscapeRight:
                rotateAngle = M_PI / 2.0f;
                break;
            default: // as UIInterfaceOrientationPortrait
                rotateAngle = 0.0;
                break;
        }
        self.zoomedView.transform = CGAffineTransformMakeRotation(rotateAngle);
    }
    
    for (UIGestureRecognizer *gr in self.zoomedView.gestureRecognizers) {
        gr.enabled = NO;
    }
    
    // View hiearchy
    self.frame = inView.bounds;
    [inView addSubview:self];
    
    self.superView = self.zoomedView.superview;
    if (self.superview) {
        [self.zoomedView removeFromSuperview];
    }
    [self addSubview:self.zoomedView];
    self.zoomedView.frame = self.convertedFrame;
    
    // Calculate zoomed frame
    CGSize withinSize = inView.frame.size;
    CGFloat widthScale = withinSize.width / self.zoomedView.width;
    CGFloat heightScale = withinSize.height / self.zoomedView.height;
    CGFloat scale = MIN(widthScale, heightScale);
    CGFloat newWidth = floorf(self.zoomedView.width * scale);
    CGFloat newHeight = floorf(self.zoomedView.height * scale);
    CGRect zoomedFrame = self.bounds;
    if (!fullscreen) {
        zoomedFrame = CGRectMake(floorf((inView.frame.size.width - newWidth) / 2), floorf((inView.frame.size.height - newHeight) / 2), newWidth, newHeight);
    }
    
    if (newWidth > newHeight && ![view isKindOfClass:[MKMapView class]]) {
        self.shouldRotate = isDeviceIPad() ? NO : YES;
    } else {
        self.shouldRotate = NO;
    }
    
//    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    [UIView animateWithDuration:ZOOM_DURATION delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.backgroundView.alpha = 1.0;
    } completion:^(BOOL finished) {
        // Rotate/Zoom image if necessary
        [UIView animateWithDuration:ZOOM_DURATION delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            
            if (self.shouldRotate) {
                CGRect rotatedFrame;
                CGSize withinSize = CGSizeMake(inView.height, inView.width);
                CGFloat widthScale = withinSize.width / self.zoomedView.width;
                CGFloat heightScale = withinSize.height / self.zoomedView.height;
                CGFloat scale = MIN(widthScale, heightScale);
                CGFloat newWidth = floorf(self.zoomedView.width * scale);
                CGFloat newHeight = floorf(self.zoomedView.height * scale);
                rotatedFrame = CGRectMake(floorf((withinSize.height - newHeight) / 2), floorf((withinSize.width - newWidth) / 2), newHeight, newWidth);
                
                self.zoomedView.transform = CGAffineTransformMakeRotation(M_PI_2);
                self.zoomedView.frame = rotatedFrame;
            } else {
                self.zoomedView.frame = zoomedFrame;
            }
        } completion:^(BOOL finished){
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }];
    }];
}

- (void)dismiss:(UITapGestureRecognizer *)gestureRecognizer {
    [self dismissWithAnimation:YES];
    
}

- (void)dismissWithAnimation:(BOOL)animated {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    CGFloat animationDuration = animated ? ZOOM_DURATION : 0.0;
    
    if ([self.zoomedView isKindOfClass:[MKMapView class]]) {
        [(MKMapView *)self.zoomedView deselectAnnotation:[[(MKMapView *)self.zoomedView annotations] lastObject] animated:NO];
    }

    [UIView animateWithDuration:animationDuration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        if (self.shouldRotate) self.zoomedView.transform = CGAffineTransformIdentity;
        self.zoomedView.frame = self.convertedFrame;
    } completion:^(BOOL finished){
        [UIView animateWithDuration:animationDuration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.backgroundView.alpha = 0.0;
        } completion:^(BOOL finished){
            for (UIGestureRecognizer *gr in self.zoomedView.gestureRecognizers) {
                gr.enabled = YES;
            }
            
            if ([self.zoomedView isKindOfClass:[MKMapView class]]) {
                [(MKMapView *)self.zoomedView setRegion:self.oldMapRegion animated:YES];
                [(MKMapView *)self.zoomedView setScrollEnabled:NO];
                [(MKMapView *)self.zoomedView setZoomEnabled:NO];
            }
            [self.zoomedView removeFromSuperview];
            
            if (self.superView) {
                self.zoomedView.frame = self.originalFrame;
                [self.superView addSubview:self.zoomedView];
            }
            [self removeFromSuperview];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(zoomViewDidDismiss:)]) {
                [self.delegate zoomViewDidDismiss:self];
            }
            
            self.superView = nil;
            self.zoomedView = nil;
            self.isZooming = NO;
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }];
    }];
}

- (void)reset {
    // This causes a crash with setFrame:
//    [self dismissWithAnimation:NO];
    
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [self.zoomedView removeFromSuperview];
    [self removeFromSuperview];
    self.isZooming = NO;
}

#pragma mark - Orientation
- (void)orientationDidChange:(NSNotification *)notification {

}

#pragma mark - Positioning (Rotation and Keyboard)
- (void)positionSelf:(NSNotification*)notification {
    CGFloat keyboardHeight;
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    NSDictionary *keyboardInfo = [notification userInfo];
    CGRect keyboardFrame = [[keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    
    [[keyboardInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[keyboardInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    
    if (notification.name == UIKeyboardWillShowNotification || notification.name == UIKeyboardDidShowNotification) {
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            keyboardHeight = keyboardFrame.size.height;
        } else {
            keyboardHeight = keyboardFrame.size.width;
        }
    } else {
        keyboardHeight = 0;
    }
    
    CGRect orientationFrame = [UIScreen mainScreen].bounds;
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        CGFloat temp = orientationFrame.size.width;
        orientationFrame.size.width = orientationFrame.size.height;
        orientationFrame.size.height = temp;
        
        temp = statusBarFrame.size.width;
        statusBarFrame.size.width = statusBarFrame.size.height;
        statusBarFrame.size.height = temp;
    }
    
    CGFloat activeHeight = orientationFrame.size.height;
    
    activeHeight -= keyboardHeight;
    CGFloat posY = floorf(activeHeight * 0.5);
    CGFloat posX = orientationFrame.size.width / 2;
    
    CGPoint newCenter;
    CGFloat rotateAngle;
    
    switch (orientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
            rotateAngle = M_PI;
            newCenter = CGPointMake(posX, orientationFrame.size.height - posY);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            rotateAngle = -M_PI / 2.0f;
            newCenter = CGPointMake(posY, posX);
            break;
        case UIInterfaceOrientationLandscapeRight:
            rotateAngle = M_PI / 2.0f;
            newCenter = CGPointMake(orientationFrame.size.height - posY, posX);
            break;
        default: // as UIInterfaceOrientationPortrait
            rotateAngle = 0.0;
            newCenter = CGPointMake(posX, posY);
            break;
    }
    
    [UIView animateWithDuration:animationDuration delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        [self moveToPoint:newCenter rotateAngle:rotateAngle];
    } completion:NULL];
    
}

- (void)moveToPoint:(CGPoint)newCenter rotateAngle:(CGFloat)angle {
    self.transform = CGAffineTransformMakeRotation(angle);
    self.center = newCenter;
}



@end
