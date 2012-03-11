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

@property (nonatomic, assign) UIView *superView;
@property (nonatomic, assign) UIView *zoomedView;
@property (nonatomic, retain) UIView *backgroundView;
@property (nonatomic, assign) CGRect convertedFrame;
@property (nonatomic, assign) CGRect originalFrame;
@property (nonatomic, assign) MKCoordinateRegion oldMapRegion;
@property (nonatomic, assign) BOOL shouldRotate;

- (void)showView:(UIView *)view withFrame:(CGRect)frame inView:(UIView *)inView fullscreen:(BOOL)fullscreen;
- (void)dismiss:(UITapGestureRecognizer *)gr;

@end

@implementation PSZoomView

@synthesize
superView = _superView,
zoomedView = _zoomedView,
backgroundView = _backgroundView,
convertedFrame = _convertedFrame,
originalFrame = _originalFrame,
oldMapRegion = _oldMapRegion,
shouldRotate = _shouldRotate;

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
        
        self.backgroundView = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundView.backgroundColor = [UIColor blackColor];
        self.backgroundView.alpha = 0.0;
        [self addSubview:self.backgroundView];
        
        UITapGestureRecognizer *gr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)] autorelease];
        [self addGestureRecognizer:gr];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}
//
//- (id)initWithMapView:(MKMapView *)mapView mapRegion:(MKCoordinateRegion)mapRegion superView:(UIView *)superView {
//    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
//    if (self) {
//        self.isMapView = YES;
//        self.superView = superView;
//        self.oldMapRegion = mapRegion;
//        
//        
//
//        
//        self.zoomView = mapView;
//        self.zoomView.frame = self.bounds;
//        self.zoomView.alpha = 0.0;
//        self.zoomView.clipsToBounds = YES;
//        self.zoomView.userInteractionEnabled = YES;
//        self.zoomView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        [(MKMapView *)self.zoomView setScrollEnabled:YES];
//        [(MKMapView *)self.zoomView setZoomEnabled:YES];
//        [self addSubview:self.zoomView];
//        
//        for (UIGestureRecognizer *gr in self.zoomView.gestureRecognizers) {
//            gr.enabled = NO;
//        }
//        
//        UITapGestureRecognizer *gr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)] autorelease];
//        [self addGestureRecognizer:gr];
//    }
//    return self;
//}
//
//- (id)initWithView:(UIView *)view superView:(UIView *)superView {
//    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
//    if (self) {
//        self.isMapView = NO;
//        self.superView = superView;
//        
//        CGSize withinSize = self.bounds.size;
//        CGFloat widthScale = withinSize.width / view.bounds.size.width;
//        CGFloat heightScale = withinSize.height / view.bounds.size.height;
//        CGFloat scale = MIN(widthScale, heightScale);
//        CGFloat newWidth = floorf(view.bounds.size.width * scale);
//        CGFloat newHeight = floorf(view.bounds.size.height * scale);
//        self.newFrame = CGRectMake(floorf((self.width - newWidth) / 2), floorf((self.height - newHeight) / 2), newWidth, newHeight);
//        
//        self.backgroundView = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
//        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        self.backgroundView.backgroundColor = [UIColor blackColor];
//        self.backgroundView.alpha = 0.0;
//        [self addSubview:self.backgroundView];
//        
//        self.zoomView = view;
//        self.zoomView.frame = self.newFrame;
//        self.zoomView.alpha = 0.0;
//        self.zoomView.clipsToBounds = YES;
//        [self addSubview:self.zoomView];
//        
//        for (UIGestureRecognizer *gr in self.zoomView.gestureRecognizers) {
//            gr.enabled = NO;
//        }
//        
//        UITapGestureRecognizer *gr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)] autorelease];
//        [self addGestureRecognizer:gr];
//    }
//    return self;
//}
//

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.backgroundView = nil;

    [super dealloc];
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
    PSImageView *iv = [[[PSImageView alloc] initWithImage:[[image copy] autorelease]] autorelease];
    [[[self class] sharedView] showView:iv withFrame:frame inView:inView fullscreen:NO];
}

- (void)showView:(UIView *)view withFrame:(CGRect)frame inView:(UIView *)inView fullscreen:(BOOL)fullscreen {
    self.zoomedView = view;
    self.convertedFrame = frame;
    self.originalFrame = view.frame;
    
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
        self.shouldRotate = YES;
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


- (void)dismiss:(UITapGestureRecognizer *)gr {
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

    [UIView animateWithDuration:ZOOM_DURATION delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        if (self.shouldRotate) self.zoomedView.transform = CGAffineTransformIdentity;
        self.zoomedView.frame = self.convertedFrame;
    } completion:^(BOOL finished){
        [UIView animateWithDuration:ZOOM_DURATION delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
//            self.zoomView.alpha = 0.0;
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
            
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }];
    }];
}

#pragma mark - Orientation
- (void)orientationDidChange:(NSNotification *)notification {
    
}


@end
