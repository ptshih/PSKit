//
//  PSZoomView.h
//  OSnap
//
//  Created by Peter Shih on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PSView.h"

@interface PSZoomView : PSView

+ (id)sharedView;

- (id)initWithView:(UIView *)view superView:(UIView *)superView;
- (id)initWithMapView:(MKMapView *)mapView mapRegion:(MKCoordinateRegion)mapRegion superView:(UIView *)superView;
- (id)initWithImage:(UIImage *)image contentMode:(UIViewContentMode)contentMode;


+ (void)showMapView:(MKMapView *)mapView withFrame:(CGRect)frame inView:(UIView *)inView fullscreen:(BOOL)fullscreen;
+ (void)showView:(UIView *)view withFrame:(CGRect)frame inView:(UIView *)inView fullscreen:(BOOL)fullscreen;
+ (void)showImage:(UIImage *)image withFrame:(CGRect)frame inView:(UIView *)inView;

@end
