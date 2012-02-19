//
//  AirWomp.m
//  Linsanity
//
//  Created by Peter on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AirWomp.h"

typedef enum {
    AirWompTypeSurvey = 1,
    AirWompTypeLink = 2,
    AirWompTypeVideo = 3
} AirWompType;

#pragma mark - AWAlert Model

@interface AWAlert : NSObject

@property (nonatomic, retain) NSDictionary *dictionary;
@property (nonatomic, assign) AirWompType type;
@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL action;
@property (nonatomic, assign) BOOL hasBlock;
@property (nonatomic, copy) void (^Block)(void);

@end


@implementation AWAlert


@synthesize
dictionary = _dictionary,
type = _type,
target = _target,
action = _action,
hasBlock = _hasBlock,
Block = _Block;



@end




#pragma mark - AirWomp Alert View

@interface AWAlertView : UIAlertView

@property (nonatomic, retain) AWAlert *alert;

@end


@implementation AWAlertView

@synthesize
alert = _alert;

@end





#pragma mark - AirWomp Manager

static AirWomp *__sharedSession = nil;

@interface AirWomp () <UIAlertViewDelegate>

@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, retain) NSMutableArray *pendingAlerts;

+ (AirWomp *)sharedSession;

// Alert Presentation
- (void)presentExternalURLWithAlert:(AWAlert *)alert;

// Alert Retrieval
- (AWAlert *)pendingAlert;

// Alert finished
- (void)alertDidFinish:(AWAlert *)alert;
- (void)alertDidFinishWithTarget:(id)target action:(SEL)action;
- (void)alertDidFinishWithBlock:(void (^)(void))block;

@end


@implementation AirWomp

@synthesize
appKey = _appKey,
pendingAlerts = _pendingAlerts;

#pragma mark - Private
+ (AirWomp *)sharedSession {
    if (!__sharedSession) {
        __sharedSession = [[self alloc] init];
    }
    return __sharedSession;
}

- (id)init {
    self = [super init];
    if (self) {
        self.pendingAlerts = [NSMutableArray arrayWithCapacity:3];
        
#warning TESTING
        AWAlert *testAlert = [[[AWAlert alloc] init] autorelease];
        NSDictionary *testAlertDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"link", @"type",
                                   @"http://itunes.apple.com/us/app/angry-birds/id343200656?mt=8&uo=4", @"link",
                                   @"Angry Birds", @"title",
                                   @"Download the new Angry Birds?", @"message",
                                   @"Okay", @"acceptText",
                                   @"No Thanks", @"declineText",
                                   nil];
        testAlert.dictionary = testAlertDict;
        testAlert.type = AirWompTypeLink;
        [self.pendingAlerts addObject:testAlert];
        
        AWAlert *testVideoAlert = [[[AWAlert alloc] init] autorelease];
        NSDictionary *testVideoAlertDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @"video", @"type",
                                       @"http://www.youtube.com/watch?v=hzixp8s4pyg", @"link",
                                       @"Ice Age 4", @"title",
                                       @"Coming to theaters July 13th, 2012. Watch the trailer now?", @"message",
                                       @"Watch", @"acceptText",
                                       @"Skip", @"declineText",
                                       nil];
        testVideoAlert.dictionary = testVideoAlertDict;
        testVideoAlert.type = AirWompTypeLink;
        [self.pendingAlerts addObject:testVideoAlert];
        
        AWAlert *testSurveyAlert = [[[AWAlert alloc] init] autorelease];
        NSDictionary *testSurveyAlertDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                            @"survey", @"type",
                                            @"Trivia", @"title",
                                            @"Which is better?", @"message",
                                            @"Coca Cola", @"acceptText",
                                            @"Pepsi", @"declineText",
                                            nil];
        testSurveyAlert.dictionary = testSurveyAlertDict;
        testSurveyAlert.type = AirWompTypeSurvey;
        [self.pendingAlerts addObject:testSurveyAlert];
                                   
    }
    return self;
}

- (void)dealloc {
    self.appKey = nil;
    self.pendingAlerts = nil;
    [super dealloc];
}

#pragma mark - Delegate
- (void)alertView:(AWAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    AWAlert *alert = alertView.alert;
    if (alertView.cancelButtonIndex == buttonIndex) {
        [self alertDidFinish:alert];
    } else {
        // YES
        AirWompType type = alertView.alert.type;
        
        switch (type) {
            case AirWompTypeSurvey:
            {
                // Log survey results
                [self alertDidFinish:alert];
                break;
            }
            case AirWompTypeLink:
            {
                // Launch external link
                [self presentExternalURLWithAlert:alert];
                break;
            }
            case AirWompTypeVideo:
            {
                // Launch external video
                [self presentExternalURLWithAlert:alert];
                break;
            }
            default:
                break;
        }
    }
}

// Alert Presentation
- (void)presentExternalURLWithAlert:(AWAlert *)alert {
    NSDictionary *alertDict = alert.dictionary;
    
    NSURL *URL = [NSURL URLWithString:[alertDict objectForKey:@"link"]];
    [[UIApplication sharedApplication] openURL:URL];
}

// Alert Retrieval
- (AWAlert *)pendingAlert {
    AWAlert *pendingAlert = nil;
    if (self.pendingAlerts && [self.pendingAlerts count] > 0) {
        pendingAlert = [self.pendingAlerts objectAtIndex:0];
        [pendingAlert retain];
        [self.pendingAlerts removeObject:pendingAlert];
        [pendingAlert autorelease];
    }
    return pendingAlert;
}

// Alert finished
- (void)alertDidFinish:(AWAlert *)alert {
    if (alert.hasBlock) {
        [self alertDidFinishWithBlock:alert.Block];
    } else {
        [self alertDidFinishWithTarget:alert.target action:alert.action];
    }
}

- (void)alertDidFinishWithTarget:(id)target action:(SEL)action {
    if (target && action) {
        [target performSelector:action];
    }
}

- (void)alertDidFinishWithBlock:(void (^)(void))block {
    if (block) {
        block();
        Block_release(block);
    }
}

#pragma mark - Public
+ (void)startSession:(NSString *)appKey {
    [[[self class] sharedSession] setAppKey:appKey];
}

+ (void)presentAlertViewWithTarget:(id)target action:(SEL)action {
    AWAlert *alert = [[[self class] sharedSession] pendingAlert];
    if (!alert) {
        [[[self class] sharedSession] alertDidFinishWithTarget:target action:action];
        return;
    }
    
    NSDictionary *alertDict = alert.dictionary;
    
    AWAlertView *av = [[[AWAlertView alloc] initWithTitle:[alertDict objectForKey:@"title"] message:[alertDict objectForKey:@"message"] delegate:[[self class] sharedSession] cancelButtonTitle:[alertDict objectForKey:@"declineText"] otherButtonTitles:[alertDict objectForKey:@"acceptText"], nil] autorelease];
    av.alert = alert;
    av.alert.target = target;
    av.alert.action = action;
    av.alert.hasBlock = NO;
    [av show];
}

+ (void)presentAlertViewWithBlock:(void (^)(void))block {
    AWAlert *alert = [[[self class] sharedSession] pendingAlert];
    if (!alert) {
        [[[self class] sharedSession] alertDidFinishWithBlock:block];
        return;
    }
    
    NSDictionary *alertDict = alert.dictionary;
    
    AWAlertView *av = [[[AWAlertView alloc] initWithTitle:[alertDict objectForKey:@"title"] message:[alertDict objectForKey:@"message"] delegate:[[self class] sharedSession] cancelButtonTitle:[alertDict objectForKey:@"declineText"] otherButtonTitles:[alertDict objectForKey:@"acceptText"], nil] autorelease];
    av.alert = alert;
    av.alert.Block = block;
    av.alert.hasBlock = YES;
    [av show];
}

@end
