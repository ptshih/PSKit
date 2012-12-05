//
//  MKMapView+PSKit.m
//  PSKit
//
//  Created by Peter Shih on 11/7/12.
//
//

#import "MKMapView+PSKit.h"

double MKMapRectSpanDistance(MKMapRect rect) {
    
    MKMapPoint eastMapPoint = MKMapPointMake(MKMapRectGetMinX(rect), MKMapRectGetMidY(rect));
    MKMapPoint westMapPoint = MKMapPointMake(MKMapRectGetMaxX(rect), MKMapRectGetMidY(rect));
    
    return MKMetersBetweenMapPoints(eastMapPoint, westMapPoint);
}

@implementation MKMapView (PSKit)

@end
