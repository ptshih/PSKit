//
//  PSLocationCenter.m
//  MealTime
//
//  Created by Peter Shih on 8/24/11.
//  Copyright 2011 Peter Shih. All rights reserved.
//

#import "PSLocationCenter.h"

static NSInteger _distanceFilter = 300; // meters
static NSInteger _ageFilter = 60; // seconds

@implementation PSLocationCenter

@synthesize locationManager = _locationManager;
@synthesize shouldDisableAfterLocationFix = _shouldDisableAfterLocationFix;
@synthesize shouldMonitorSignificantChange = _shouldMonitorSignificantChange;
@synthesize hasGPSLock = _hasGPSLock;

+ (id)defaultCenter {
  static id defaultCenter = nil;
  if (!defaultCenter) {
    defaultCenter = [[self alloc] init];
  }
  return defaultCenter;
}

- (id)init {
  self = [super init];
  if (self) {
    _hasGPSLock = NO;
    _locationRequested = NO;
    _isUpdating = NO;
    _shouldDisableAfterLocationFix = NO;
    _shouldMonitorSignificantChange = NO;
    
    _lastLocation = nil;
    _startDate = nil;
    
    // Create the location manager if this object does not
    // already have one.
    if (!_locationManager) {
      _locationManager = [[CLLocationManager alloc] init];
      
      //    _locationManager.purpose = nil; // Displayed to user
      
      _locationManager.delegate = self;
      _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
      
      // Set a movement threshold for new events.
      _locationManager.distanceFilter = _distanceFilter;
    }
    
    [self startUpdates];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startUpdates) name:kApplicationResumed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopUpdates) name:kApplicationSuspended object:nil];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kApplicationResumed object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kApplicationSuspended object:nil];
  
  _locationManager.delegate = nil;
  INVALIDATE_TIMER(_pollTimer);
  RELEASE_SAFELY(_startDate);
  RELEASE_SAFELY(_lastLocation);
  RELEASE_SAFELY(_locationManager);
  [super dealloc];
}

#pragma mark - Location Methods
- (void)getMyLocation {
  // If a location has been requested and a previous request isn't being fulfilled
  // Check to see if we already have a lock, if so notify
  // If we have no lock, start location updates
  if (!_locationRequested) {
    _locationRequested = YES;
    
    if ([self hasAcquiredLocation]) {
      _locationRequested = NO;
      [[NSNotificationCenter defaultCenter] postNotificationName:kLocationAcquired object:nil];
    } else {
      // Start Date
      RELEASE_SAFELY(_startDate);
      _startDate = [[NSDate date] retain];
      
      INVALIDATE_TIMER(_pollTimer);
      _pollTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(pollLocation:) userInfo:nil repeats:YES];
      [[NSRunLoop currentRunLoop] addTimer:_pollTimer forMode:NSDefaultRunLoopMode];
      
      [self startUpdates]; // make sure updates is started
    }
  }
}

- (void)startUpdates {
#if TARGET_IPHONE_SIMULATOR
  if (_locationRequested) {
    _locationRequested = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationAcquired object:nil];
  }
#else
  if (!_isUpdating) {
    _isUpdating = YES;
    
    // Check location capabilities
    if ([CLLocationManager significantLocationChangeMonitoringAvailable] && _shouldMonitorSignificantChange) {
      [self.locationManager startUpdatingLocation];
      [self.locationManager startMonitoringSignificantLocationChanges];
    } else {
      [self.locationManager startUpdatingLocation];
    }
  }
#endif
}

- (void)stopUpdates {
#if TARGET_IPHONE_SIMULATOR
  
#else
  if (_isUpdating) {
    _isUpdating = NO;
  
    // Check location capabilities
    if ([CLLocationManager significantLocationChangeMonitoringAvailable] && _shouldMonitorSignificantChange) {
      [self.locationManager stopUpdatingLocation];
      [self.locationManager stopMonitoringSignificantLocationChanges];
      
//      [[NSNotificationCenter defaultCenter] removeObserver:self.locationManager name:kApplicationResumed object:nil];
//      [[NSNotificationCenter defaultCenter] removeObserver:self.locationManager name:kApplicationSuspended object:nil];
    } else {
      [self.locationManager stopUpdatingLocation];
    }
  }
#endif
}

#pragma mark - Public Accessors
- (BOOL)hasAcquiredLocation {
  if ([self location] && _hasGPSLock) return YES;
  else return NO;
}

- (CLLocation *)location {
  return _lastLocation;
//  return self.locationManager.location;
}

- (CLLocationCoordinate2D)locationCoordinate {
  return _lastLocation.coordinate;
//  return [self.locationManager.location coordinate];
}

- (CLLocationDegrees)latitude {
#if TARGET_IPHONE_SIMULATOR
  return 37.32798;
#else
  return _lastLocation.coordinate.latitude;
//  return self.locationManager.location.coordinate.latitude;
#endif
}

- (CLLocationDegrees)longitude {
#if TARGET_IPHONE_SIMULATOR
  return -122.01382;
#else
  return _lastLocation.coordinate.longitude;
//  return self.locationManager.location.coordinate.longitude;
#endif
}

- (CLLocationAccuracy)accuracy {
  return _lastLocation.horizontalAccuracy;
}

- (NSString *)locationString {
  if ([self hasAcquiredLocation]) {
    return [NSString stringWithFormat:@"%f,%f", [self latitude], [self longitude]];
  } else {
    return @"";
  }
}

#pragma mark CLLocationManagerDelegate
// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
  /**
   _lastLocation stores the last accepted acquired location whereas oldLocation may contain an unaccepted location
   
   _lastLocationDate stores the last acquired location's timestamp, regardless of if it was accepted or not
   
   Reasons to discard location
   1. Accuracy is bad (greater than threshold)
   2. Location is stale (older than 300 seconds)
   
   Reasons to accept location
   1. Time since updating started has taken more than 60 seconds
   
   Reasons to reload interface
   1. Location distance change from last known location is less than threshold
   */
  
//  CLLocationDistance distanceThreshold = 1500; // For some reason, cell tower triangulation is always = 1414
  CLLocationAccuracy accuracy = newLocation.horizontalAccuracy;
  NSTimeInterval age = fabs([[NSDate date] timeIntervalSinceDate:newLocation.timestamp]);
//  CLLocationDistance distanceChanged = _lastLocation ? [newLocation distanceFromLocation:_lastLocation] : distanceThreshold;
  
  if (age <= _ageFilter) {
    // Good Location Acquired
    DLog(@"Location updated: %@, oldLocation: %@, accuracy: %g, age: %g, distanceChanged: %g", newLocation, oldLocation, accuracy, age, [newLocation distanceFromLocation:_lastLocation]);
    
    // Set last known acquired location
    RELEASE_SAFELY(_lastLocation);
    _lastLocation = [newLocation copy];
    
    // See if we have a good GPS lock
    if (accuracy < 300) {
      _hasGPSLock = YES;
    } else {
      _hasGPSLock = NO;
    }
    
    if (_shouldDisableAfterLocationFix) {
      [self stopUpdates];
    }
  } else {
    // Bad Location Discarded
    DLog(@"Location discarded: %@, oldLocation: %@, accuracy: %g, age: %g, distanceChanged: %g", newLocation, oldLocation, accuracy, age, [newLocation distanceFromLocation:_lastLocation]);
  }
}

- (void)pollLocation:(NSTimer *)timer {
  if (!_lastLocation) return;
  
  NSTimeInterval timeSinceStart = [[NSDate date] timeIntervalSinceDate:_startDate];

  // Give it at least 3 seconds or override if has GPS lock
  if (timeSinceStart > 3.0 || _hasGPSLock) {
    // Post Notification to reload interface
    if (_locationRequested) {
      _locationRequested = NO;
      INVALIDATE_TIMER(_pollTimer);
      [[NSNotificationCenter defaultCenter] postNotificationName:kLocationAcquired object:_lastLocation];
    }
  }
}

@end
