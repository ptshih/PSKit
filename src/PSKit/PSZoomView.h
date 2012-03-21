//
//  PSZoomView.h
//  OSnap
//
//  Created by Peter Shih on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PSView.h"

@protocol PSZoomViewDelegate;

@interface PSZoomView : PSView

@property (nonatomic, assign) id <PSZoomViewDelegate> delegate;

+ (id)sharedView;

+ (void)showMapView:(MKMapView *)mapView withFrame:(CGRect)frame inView:(UIView *)inView fullscreen:(BOOL)fullscreen;
+ (void)showView:(UIView *)view withFrame:(CGRect)frame inView:(UIView *)inView fullscreen:(BOOL)fullscreen;
+ (void)showImage:(UIImage *)image withFrame:(CGRect)frame inView:(UIView *)inView;

@end

@protocol PSZoomViewDelegate <NSObject>

@optional
- (void)zoomViewDidDismiss:(PSZoomView *)zoomView;

@end