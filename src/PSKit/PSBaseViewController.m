//
//  PSBaseViewController.m
//  PhotoTime
//
//  Created by Peter Shih on 2/10/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSBaseViewController.h"

@interface PSBaseViewController (Private)

@end

@implementation PSBaseViewController

@synthesize
reloading = _reloading,
dataDidError = _dataDidError;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.reloading = NO;
        self.dataDidError = NO;
    }
    return self;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - PSStateMachine
- (BOOL)dataIsAvailable {
    return NO;
}

- (BOOL)dataIsLoading {
    return self.reloading;
}

- (void)dataSourceDidError {
}

- (void)updateState {
    if ([self dataIsAvailable]) {
        // We have data to display
    } else {
        // We don't have data available to display
        if ([self dataIsLoading]) {
            // We are loading for the first time
        } else {
            if ([self dataDidError]) {
                // There was a dataSource error, show the error screen
            } else {
                // We have no data to display, show the empty screen
            }
        }
    }
}

- (id)parseData:(id)data httpResponse:(NSHTTPURLResponse *)httpResponse {
    id results = nil;
    
    // Parse JSON if Content-Type is "application/json"
    NSString *contentType = [[httpResponse allHeaderFields] objectForKey:@"Content-Type"];
    BOOL isJSON = contentType ? [contentType rangeOfString:@"application/json"].location != NSNotFound : NO;
    if (isJSON) {
        NSError *jsonError = nil;
        results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
    } else {
        results = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    }
    return results;
}



@end