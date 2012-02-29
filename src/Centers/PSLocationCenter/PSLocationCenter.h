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

@interface PSLocationCenter : NSObject <CLLocationManagerDelegate> {
  
  NSDate *_startDate;

}

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, copy) CLLocation *location;
@property (nonatomic, retain) NSTimer *pollTimer;
@property (nonatomic, retain) NSDate *pollStartDate;
@property (nonatomic, retain) NSDate *backgroundDate;
@property (nonatomic, retain) NSDate *foregroundDate;
@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, assign) BOOL locationRequested;
@property (nonatomic, assign) BOOL shouldDisableAfterLocationFix;
@property (nonatomic, assign) BOOL shouldNotifyUpdate;

+ (id)defaultCenter;

// Public Methods
- (void)updateMyLocation;
- (BOOL)hasAcquiredLocation;
- (BOOL)hasAcquiredAccurateLocation;
- (CLLocation *)location;
- (CLLocationCoordinate2D)locationCoordinate;
- (CLLocationDegrees)latitude;
- (CLLocationDegrees)longitude;
- (CLLocationAccuracy)accuracy;

- (NSString *)locationString;
- (NSMutableDictionary *)exifLocation;

// Private Methods
- (void)startUpdates;
- (void)stopUpdates;
- (void)resumeUpdates;
- (void)suspendUpdates;
- (void)pollLocation:(NSTimer *)timer;

@end
