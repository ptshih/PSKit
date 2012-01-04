//
//  PSLocationCenter.h
//  MealTime
//
//  Created by Peter Shih on 8/24/11.
//  Copyright 2011 Peter Shih. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <ImageIO/ImageIO.h>

#define kLocationAcquired @"LocationAcquired"
#define kLocationUnchanged @"LocationUnchanged"

@interface PSLocationCenter : PSObject <CLLocationManagerDelegate> {
  CLLocationManager *_locationManager;
  CLLocation *_lastLocation; // last known good location
  
  NSDate *_startDate;
  NSTimer *_pollTimer;
  
  BOOL _hasGPSLock;
  BOOL _locationRequested;
  BOOL _isUpdating;
  BOOL _shouldDisableAfterLocationFix;
  BOOL _shouldMonitorSignificantChange;
}

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL shouldDisableAfterLocationFix;
@property (nonatomic, assign) BOOL shouldMonitorSignificantChange;
@property (nonatomic, readonly) BOOL hasGPSLock;

+ (id)defaultCenter;

// Public Methods
- (void)getMyLocation;
- (BOOL)hasAcquiredLocation;
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
- (void)pollLocation:(NSTimer *)timer;

@end
