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
backgroundView = _backgroundView,
zoomView = _zoomView,
superView = _superView,
newFrame = _newFrame,
originalFrame = _originalFrame,
shouldRotate = _shouldRotate,
isMapView = _isMapView,
oldMapRegion = _oldMapRegion;

- (id)initWithMapView:(MKMapView *)mapView mapRegion:(MKCoordinateRegion)mapRegion superView:(UIView *)superView {
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        self.isMapView = YES;
        self.superView = superView;
        self.oldMapRegion = mapRegion;
        
        self.newFrame = CGRectMake(0, 0, self.width, self.height);
        
        self.backgroundView = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundView.backgroundColor = [UIColor blackColor];
        self.backgroundView.alpha = 0.0;
        [self addSubview:self.backgroundView];
        
        self.zoomView = mapView;
        self.zoomView.frame = self.newFrame;
        self.zoomView.alpha = 0.0;
        self.zoomView.clipsToBounds = YES;
        self.zoomView.userInteractionEnabled = YES;
        [(MKMapView *)self.zoomView setScrollEnabled:YES];
        [(MKMapView *)self.zoomView setZoomEnabled:YES];
        [self addSubview:self.zoomView];
        
        for (UIGestureRecognizer *gr in self.zoomView.gestureRecognizers) {
            gr.enabled = NO;
        }
        
        UITapGestureRecognizer *gr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)] autorelease];
        [self addGestureRecognizer:gr];
    }
    return self;
}

- (id)initWithView:(UIView *)view superView:(UIView *)superView {
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        self.isMapView = NO;
        self.superView = superView;
        
        CGSize withinSize = self.bounds.size;
        CGFloat widthScale = withinSize.width / view.bounds.size.width;
        CGFloat heightScale = withinSize.height / view.bounds.size.height;
        CGFloat scale = MIN(widthScale, heightScale);
        CGFloat newWidth = floorf(view.bounds.size.width * scale);
        CGFloat newHeight = floorf(view.bounds.size.height * scale);
        self.newFrame = CGRectMake(floorf((self.width - newWidth) / 2), floorf((self.height - newHeight) / 2), newWidth, newHeight);
        
        self.backgroundView = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundView.backgroundColor = [UIColor blackColor];
        self.backgroundView.alpha = 0.0;
        [self addSubview:self.backgroundView];
        
        self.zoomView = view;
        self.zoomView.frame = self.newFrame;
        self.zoomView.alpha = 0.0;
        self.zoomView.clipsToBounds = YES;
        [self addSubview:self.zoomView];
        
        for (UIGestureRecognizer *gr in self.zoomView.gestureRecognizers) {
            gr.enabled = NO;
        }
        
        UITapGestureRecognizer *gr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)] autorelease];
        [self addGestureRecognizer:gr];
    }
    return self;
}

- (id)initWithImage:(UIImage *)image contentMode:(UIViewContentMode)contentMode {    
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        self.isMapView = NO;
        self.shouldRotate = [image isLandscape];
        
        CGSize withinSize = self.bounds.size;
        CGFloat widthScale = withinSize.width / image.size.width;
        CGFloat heightScale = withinSize.height / image.size.height;
        CGFloat scale = MIN(widthScale, heightScale);
        CGFloat newWidth = floorf(image.size.width * scale);
        CGFloat newHeight = floorf(image.size.height * scale);
        self.newFrame = CGRectMake(floorf((self.width - newWidth) / 2), floorf((self.height - newHeight) / 2), newWidth, newHeight);
        
//        NSLog(@"new frame: %@", NSStringFromCGRect(self.newFrame));
        
        self.backgroundView = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundView.backgroundColor = [UIColor blackColor];
        self.backgroundView.alpha = 0.0;
        [self addSubview:self.backgroundView];
        
        self.zoomView = [[[UIImageView alloc] initWithImage:image] autorelease];
        self.zoomView.frame = self.newFrame;
        self.zoomView.alpha = 0.0;
        self.zoomView.clipsToBounds = YES;
        self.zoomView.contentMode = contentMode;
        [self addSubview:self.zoomView];
        
        UITapGestureRecognizer *gr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)] autorelease];
        [self addGestureRecognizer:gr];
    }
    return self;
}

- (void)dealloc {
    self.backgroundView = nil;
    self.zoomView = nil;

    [super dealloc];
}

- (void)showInRect:(CGRect)rect {
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    self.frame = [[UIScreen mainScreen] bounds];
    self.backgroundView.frame = self.bounds;
    
    self.originalFrame = rect;
    self.zoomView.frame = self.originalFrame;
    
    [[APP_DELEGATE window] addSubview:self];
    
    [UIView animateWithDuration:ZOOM_DURATION delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.zoomView.alpha = 1.0;
        self.backgroundView.alpha = 1.0;
    } completion:^(BOOL finished) {
        // Rotate/Zoom image if necessary
        [UIView animateWithDuration:ZOOM_DURATION delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            if (self.shouldRotate) {
                CGSize withinSize = CGSizeMake(self.bounds.size.height, self.bounds.size.width);
                CGFloat widthScale = withinSize.width / self.newFrame.size.width;
                CGFloat heightScale = withinSize.height / self.newFrame.size.height;
                CGFloat scale = MIN(widthScale, heightScale);
                self.newFrame = CGRectMake(floorf((self.width - self.newFrame.size.width * scale) / 2), floorf((self.height - self.newFrame.size.height * scale) / 2), self.newFrame.size.width * scale, self.newFrame.size.height * scale);
                self.zoomView.frame = self.newFrame;
                self.zoomView.transform = CGAffineTransformMakeRotation(0.5 * M_PI);                
            } else {
                self.zoomView.frame = self.newFrame;
            }
        } completion:^(BOOL finished){
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }];
    }];
}

- (void)dismiss {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

    [UIView animateWithDuration:ZOOM_DURATION delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        if (self.shouldRotate) self.zoomView.transform = CGAffineTransformIdentity;
        self.zoomView.frame = self.originalFrame;
    } completion:^(BOOL finished){
        [UIView animateWithDuration:ZOOM_DURATION delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
//            self.zoomView.alpha = 0.0;
            self.backgroundView.alpha = 0.0;
        } completion:^(BOOL finished){
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            if (self.superView) {
                for (UIGestureRecognizer *gr in self.zoomView.gestureRecognizers) {
                    gr.enabled = YES;
                }
                if (self.isMapView) {
                    [(MKMapView *)self.zoomView setRegion:self.oldMapRegion animated:YES];
                    [(MKMapView *)self.zoomView setScrollEnabled:NO];
                    [(MKMapView *)self.zoomView setZoomEnabled:NO];
                }
                CGRect convertedRect = [self.superView convertRect:self.originalFrame fromView:nil];
                self.zoomView.frame = convertedRect;
                [self.superView addSubview:self.zoomView];
            }
            [self removeFromSuperview];
        }];
    }];
}

@end
