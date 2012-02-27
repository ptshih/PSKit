//
//  PSZoomView.h
//  OSnap
//
//  Created by Peter Shih on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PSView.h"

@interface PSZoomView : PSView

@property (nonatomic, retain) UIView *backgroundView;
@property (nonatomic, retain) UIView *zoomView;
@property (nonatomic, assign) UIView *superView;
@property (nonatomic, assign) CGRect newFrame;
@property (nonatomic, assign) CGRect originalFrame;
@property (nonatomic, assign) BOOL shouldRotate;
@property (nonatomic, assign) BOOL isMapView;
@property (nonatomic, assign) MKCoordinateRegion oldMapRegion;

- (id)initWithView:(UIView *)view superView:(UIView *)superView;
- (id)initWithMapView:(MKMapView *)mapView mapRegion:(MKCoordinateRegion)mapRegion superView:(UIView *)superView;
- (id)initWithImage:(UIImage *)image contentMode:(UIViewContentMode)contentMode;
- (void)showInRect:(CGRect)rect;

@end
