//
//  PSLocationCenter.m
//  MealTime
//
//  Created by Peter Shih on 8/24/11.
//  Copyright 2011 Peter Shih. All rights reserved.
//

#import "PSLocationCenter.h"

static const CLLocationDistance __systemDistanceFilter = 10;
static const CLLocationDistance __updateDistanceFilter = 100;
static const CLLocationDistance __thresholdDistanceFilter = 10;
static const NSTimeInterval __locationAgeThreshold = 5 * 60; // seconds after which an update is considered stale
static const NSTimeInterval __pollDuration = 30;

@implementation PSLocationCenter

@synthesize
locationManager = _locationManager,
location = _location,
pollTimer = _pollTimer,
pollStartDate = _pollStartDate,
isActive = _isActive,
locationRequested = _locationRequested,
shouldDisableAfterLocationFix = _shouldDisableAfterLocationFix;

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
        self.locationManager = [[[CLLocationManager alloc] init] autorelease];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.locationManager.distanceFilter = __systemDistanceFilter;
        
        self.location = nil;
//#if TARGET_IPHONE_SIMULATOR
//        self.location = [[[CLLocation alloc]initWithCoordinate:CLLocationCoordinate2DMake(40.724250, -73.997394)
//                                                    altitude:77
//                                          horizontalAccuracy:88
//                                            verticalAccuracy:99
//                                                   timestamp:[NSDate date]] autorelease];
//#endif
        
        self.isActive = NO;
        self.locationRequested = NO;
        self.shouldDisableAfterLocationFix = NO;
        
        if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
            [self.locationManager startMonitoringSignificantLocationChanges];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeUpdates) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(suspendUpdates) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    self.locationManager.delegate = nil;
    self.locationManager = nil;
    self.location = nil;
    
    [self.pollTimer invalidate];
    self.pollTimer = nil;
    
    self.pollStartDate = nil;
    
    [super dealloc];
}

#pragma mark - Location Methods
- (void)updateMyLocation {
    
    
    // If a location has been requested and a previous request isn't being fulfilled
    // Check to see if we already have a lock, if so notify
    // If we have no lock, start location updates
    if (!self.locationRequested) {
        self.locationRequested = YES;
        
        // Reset last found location
        self.location = nil;
        self.pollStartDate = [NSDate date];
        
        [self.pollTimer invalidate];
        self.pollTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(pollLocation:) userInfo:nil repeats:YES];
        
        [self startUpdates];
    }
}

- (void)pollLocation:(NSTimer *)timer {
    NSTimeInterval timeSinceStart = [[NSDate date] timeIntervalSinceDate:self.pollStartDate];
    
    if ((self.location && self.location.horizontalAccuracy < kCLLocationAccuracyNearestTenMeters) || timeSinceStart > __pollDuration) {
        self.locationRequested = NO;
        [self.pollTimer invalidate];
        self.pollTimer = nil;
    }
}

#pragma mark CLLocationManagerDelegate
// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {        
    
    //  CLLocationDistance distanceThreshold = 1500; // For some reason, cell tower triangulation is always = 1414
    CLLocationAccuracy accuracy = newLocation.horizontalAccuracy;
    NSTimeInterval age = fabs([[NSDate date] timeIntervalSinceDate:newLocation.timestamp]);
    CLLocationDistance distanceChanged = [newLocation distanceFromLocation:self.location];
    
    if (age <= __locationAgeThreshold && accuracy < __updateDistanceFilter && accuracy > 0) {
        // Good Location Acquired
        DLog(@"Location updated: %@, oldLocation: %@, accuracy: %g, age: %g, distanceChanged: %g", newLocation, oldLocation, accuracy, age, distanceChanged);
        
        if (distanceChanged > __thresholdDistanceFilter || distanceChanged == -1) {
            self.location = newLocation;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kPSLocationCenterDidUpdate object:nil];
        }
    } else {
        DLog(@"Location discarded: %@, oldLocation: %@, accuracy: %g, age: %g, distanceChanged: %g", newLocation, oldLocation, accuracy, age, distanceChanged);
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:kPSLocationCenterDidFail object:nil userInfo:[NSDictionary dictionaryWithObject:error forKey:@"error"]];
}

#pragma mark - Start/Stop/Resume/Suspend
- (void)startUpdates {
    if (!self.isActive) {
        self.isActive = YES;
        [self.locationManager startUpdatingLocation];
    }
}

- (void)stopUpdates {
    if (self.isActive) {
        self.isActive = NO;
        [self.locationManager stopUpdatingLocation];
    }
}

- (void)resumeUpdates {
    [self startUpdates];
    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
        [self.locationManager startMonitoringSignificantLocationChanges];
    }
}

- (void)suspendUpdates {
    [self stopUpdates];
    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
        [self.locationManager stopMonitoringSignificantLocationChanges];
    }
}

#pragma mark - Public Accessors
- (BOOL)hasAcquiredLocation {
    if (self.location) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)hasAcquiredAccurateLocation {
    if (self.location && self.location.horizontalAccuracy < __updateDistanceFilter) {
        return YES;
    } else {
        return NO;
    }
}

- (CLLocationCoordinate2D)locationCoordinate {
    return self.location.coordinate;
}

- (CLLocationDegrees)latitude {
    return self.location.coordinate.latitude;
}

- (CLLocationDegrees)longitude {
    return self.location.coordinate.longitude;
}

- (CLLocationAccuracy)accuracy {
    return self.location.horizontalAccuracy;
}

- (NSString *)locationString {
    if ([self hasAcquiredLocation]) {
        return [NSString stringWithFormat:@"%f,%f", [self latitude], [self longitude]];
    } else {
        return @"";
    }
}

#pragma mark - Exif Location
- (NSMutableDictionary *)exifLocation {
    NSMutableDictionary *locDict = [[NSMutableDictionary alloc] init];
    CLLocation *location = [self location];
    
    if (location) {
        CLLocationDegrees exifLatitude = location.coordinate.latitude;
        CLLocationDegrees exifLongitude = location.coordinate.longitude;
        
        [locDict setObject:location.timestamp forKey:(NSString*)kCGImagePropertyGPSTimeStamp];
        
        if (exifLatitude < 0.0) {
            exifLatitude = exifLatitude*(-1);
            [locDict setObject:@"S" forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
        } else {
            [locDict setObject:@"N" forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
        }
        [locDict setObject:[NSNumber numberWithFloat:exifLatitude] forKey:(NSString*)kCGImagePropertyGPSLatitude];
        
        if (exifLongitude < 0.0) {
            exifLongitude=exifLongitude*(-1);
            [locDict setObject:@"W" forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
        } else {
            [locDict setObject:@"E" forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
        }
        [locDict setObject:[NSNumber numberWithFloat:exifLongitude] forKey:(NSString*) kCGImagePropertyGPSLongitude];
    }
    
    return [locDict autorelease];
}

@end
