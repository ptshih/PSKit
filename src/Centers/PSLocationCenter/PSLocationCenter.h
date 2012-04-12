//
//  PSLocationCenter.h
//  PSKit
//
//  Created by Peter Shih on 8/24/11.
//  Copyright 2011 Peter Shih. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <ImageIO/ImageIO.h>

#define kPSLocationCenterDidUpdate @"kPSLocationCenterDidUpdate"
#define kPSLocationCenterDidFail @"kPSLocationCenterDidFail"

@interface PSLocationCenter : NSObject <CLLocationManagerDelegate>

@property (nonatomic, copy, readonly) CLLocation *location;
@property (nonatomic, retain, readonly) CLGeocoder *geocoder;

+ (id)defaultCenter;

// Public Methods
- (BOOL)hasAcquiredLocation;
- (BOOL)hasAcquiredAccurateLocation;
- (BOOL)locationServicesAuthorized;
- (CLLocationCoordinate2D)locationCoordinate;
- (CLLocationDegrees)latitude;
- (CLLocationDegrees)longitude;
- (CLLocationAccuracy)accuracy;

- (NSString *)locationString;
- (NSMutableDictionary *)exifLocation;

- (void)resumeUpdates;
- (void)suspendUpdates;

@end
