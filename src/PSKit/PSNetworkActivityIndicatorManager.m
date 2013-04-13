//
//  PSNetworkActivityIndicatorManager.m
//  Celery
//
//  Created by Peter Shih on 4/12/13.
//
//

#import "PSNetworkActivityIndicatorManager.h"

static NSTimeInterval const kPSNetworkActivityIndicatorInvisibilityDelay = 0.17;

@interface PSNetworkActivityIndicatorManager ()

@property (readwrite, assign) NSInteger activityCount;
@property (readwrite, nonatomic, strong) NSTimer *activityIndicatorVisibilityTimer;
@property (readonly, getter = isNetworkActivityIndicatorVisible) BOOL networkActivityIndicatorVisible;

- (void)updateNetworkActivityIndicatorVisibility;
- (void)updateNetworkActivityIndicatorVisibilityDelayed;

@end

@implementation PSNetworkActivityIndicatorManager

@synthesize activityCount = _activityCount;
@synthesize activityIndicatorVisibilityTimer = _activityIndicatorVisibilityTimer;
@synthesize enabled = _enabled;
@dynamic networkActivityIndicatorVisible;

+ (instancetype)sharedManager {
    static PSNetworkActivityIndicatorManager *_sharedManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

+ (NSSet *)keyPathsForValuesAffectingIsNetworkActivityIndicatorVisible {
    return [NSSet setWithObject:@"activityCount"];
}

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkingOperationDidStart:) name:PSNetworkingOperationDidStartNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkingOperationDidFinish:) name:PSNetworkingOperationDidFinishNotification object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_activityIndicatorVisibilityTimer invalidate];
}

- (void)updateNetworkActivityIndicatorVisibilityDelayed {
    if (self.enabled) {
        // Delay hiding of activity indicator for a short interval, to avoid flickering
        if (![self isNetworkActivityIndicatorVisible]) {
            [self.activityIndicatorVisibilityTimer invalidate];
            self.activityIndicatorVisibilityTimer = [NSTimer timerWithTimeInterval:kPSNetworkActivityIndicatorInvisibilityDelay target:self selector:@selector(updateNetworkActivityIndicatorVisibility) userInfo:nil repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:self.activityIndicatorVisibilityTimer forMode:NSRunLoopCommonModes];
        } else {
            [self performSelectorOnMainThread:@selector(updateNetworkActivityIndicatorVisibility) withObject:nil waitUntilDone:NO modes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
        }
    }
}

- (BOOL)isNetworkActivityIndicatorVisible {
    return _activityCount > 0;
}

- (void)updateNetworkActivityIndicatorVisibility {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:[self isNetworkActivityIndicatorVisible]];
}

// Not exposed, but used if activityCount is set via KVC.
- (NSInteger)activityCount {
	return _activityCount;
}

- (void)setActivityCount:(NSInteger)activityCount {
	@synchronized(self) {
		_activityCount = activityCount;
	}
    [self updateNetworkActivityIndicatorVisibilityDelayed];
}

- (void)incrementActivityCount {
    [self willChangeValueForKey:@"activityCount"];
	@synchronized(self) {
		_activityCount++;
	}
    [self didChangeValueForKey:@"activityCount"];
    [self updateNetworkActivityIndicatorVisibilityDelayed];
}

- (void)decrementActivityCount {
    [self willChangeValueForKey:@"activityCount"];
	@synchronized(self) {
		_activityCount = MAX(_activityCount - 1, 0);
	}
    [self didChangeValueForKey:@"activityCount"];
    [self updateNetworkActivityIndicatorVisibilityDelayed];
}

- (void)networkingOperationDidStart:(NSNotification *)notification {
    [self incrementActivityCount];
}

- (void)networkingOperationDidFinish:(NSNotification *)notification {
    [self decrementActivityCount];
}


@end
