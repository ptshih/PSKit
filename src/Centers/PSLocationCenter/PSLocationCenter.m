//
//  PSLocationCenter.m
//  PSKit
//
//  Created by Peter Shih on 8/24/11.
//  Copyright 2011 Peter Shih. All rights reserved.
//

#import "PSLocationCenter.h"

//  CLLocationDistance __accuracyThreshold = 1500; // For some reason, cell tower triangulation is always = 1414
static const CLLocationDistance __accuracyThreshold = 1500;
static const CLLocationDistance __updateDistanceFilter = 500;
static const NSTimeInterval __locationAgeThreshold = 5 * 60; // seconds after which an update is considered stale
static const NSTimeInterval __pollDuration = 30;

@interface PSLocationCenter ()

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, copy) CLLocation *location;
@property (nonatomic, retain) CLGeocoder *geocoder;
@property (nonatomic, retain) NSDate *backgroundDate;
@property (nonatomic, retain) NSDate *foregroundDate;
@property (nonatomic, assign) BOOL shouldDisableAfterLocationFix;

@end

@implementation PSLocationCenter

@synthesize
locationManager = _locationManager,
location = _location,
geocoder = _geocoder,
backgroundDate = _backgroundDate,
foregroundDate = _foregroundDate,
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
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = __updateDistanceFilter;
        
        self.location = nil;
        
        self.geocoder = [[[CLGeocoder alloc] init] autorelease];
        
        self.foregroundDate = [NSDate date];
        self.backgroundDate = [NSDate date];
        
        self.shouldDisableAfterLocationFix = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeUpdates) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(suspendUpdates) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    self.backgroundDate = nil;
    self.foregroundDate = nil;
    
    self.locationManager.delegate = nil;
    self.locationManager = nil;
    
    self.location = nil;
    self.geocoder = nil;
    
    [super dealloc];
}

#pragma mark CLLocationManagerDelegate
// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {        
    
    //  CLLocationDistance distanceThreshold = 1500; // For some reason, cell tower triangulation is always = 1414
    CLLocationAccuracy accuracy = newLocation.horizontalAccuracy;
    NSTimeInterval age = fabs([[NSDate date] timeIntervalSinceDate:newLocation.timestamp]);
    CLLocationDistance distanceChanged = [newLocation distanceFromLocation:self.location];
    
    if (age <= __locationAgeThreshold && accuracy < __accuracyThreshold && accuracy > 0) {
        // Good Location Acquired
        DLog(@"Location updated: %@, oldLocation: %@, accuracy: %g, age: %g, distanceChanged: %g", newLocation, oldLocation, accuracy, age, distanceChanged);
        
        // Set current Location
        self.location = newLocation;
        
        // Notify
        [[NSNotificationCenter defaultCenter] postNotificationName:kPSLocationCenterDidUpdate object:nil];
    } else {
        DLog(@"Location discarded: %@, oldLocation: %@, accuracy: %g, age: %g, distanceChanged: %g", newLocation, oldLocation, accuracy, age, distanceChanged);
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:kPSLocationCenterDidFail object:nil userInfo:[NSDictionary dictionaryWithObject:error forKey:@"error"]];
}

#pragma mark - Start/Stop/Resume/Suspend
- (void)resumeUpdates {
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    if (![CLLocationManager locationServicesEnabled] || (authStatus != kCLAuthorizationStatusAuthorized && authStatus != kCLAuthorizationStatusNotDetermined)) {
        // The user did not enable location services or denied it
        self.location = [[[CLLocation alloc] initWithLatitude:40.7247 longitude:-73.9995] autorelease];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kPSLocationCenterDidUpdate object:nil];
        
        UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"Lunchbox works a lot better when it knows your location. Until then... welcome to NYC!" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] autorelease];
        [av show];
    } else {
        self.foregroundDate = [NSDate date];
        NSTimeInterval secondsBackgrounded = [self.foregroundDate timeIntervalSinceDate:self.backgroundDate];
        
        // If we don't have a location yet, get one
        // If our app session expired, get a new location
        if (![self hasAcquiredLocation] || secondsBackgrounded > kSecondsBackgroundedUntilStale) {
            self.location = nil;
            [self.locationManager startUpdatingLocation];
        }
        
        if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
            [self.locationManager startMonitoringSignificantLocationChanges];
        }
    }
}

- (void)suspendUpdates {
    self.backgroundDate = [NSDate date];
    
    [self.locationManager stopUpdatingLocation];
    
    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
        [self.locationManager stopMonitoringSignificantLocationChanges];
    }
}

#pragma mark - Public Accessors
- (BOOL)locationServicesAuthorized {
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    return (authStatus == kCLAuthorizationStatusAuthorized);
}

- (BOOL)hasAcquiredLocation {
    if (self.location) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)hasAcquiredAccurateLocation {
    if (self.location) {
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
        return nil;
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
