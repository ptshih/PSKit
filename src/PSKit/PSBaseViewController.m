//
//  PSBaseViewController.m
//  PSKit
//
//  Created by Peter Shih on 2/10/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSBaseViewController.h"

@interface PSBaseViewController ()

@end

@implementation PSBaseViewController

@synthesize
requestQueue = _requestQueue,
reloading = _reloading,
hasLoadedOnce = _hasLoadedOnce,
isReload = _isReload;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.requestQueue = [[[NSOperationQueue alloc] init] autorelease];
        self.requestQueue.maxConcurrentOperationCount = 1;
        self.reloading = NO;
        self.hasLoadedOnce = NO;
        self.isReload = NO;
    }
    return self;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
    self.requestQueue = nil;
    [super dealloc];
}

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - PSStateMachine
// Data Source
- (void)loadDataSource {
    [self beginRefresh];
    self.isReload = NO;
}

- (void)reloadDataSource {
    [self beginRefresh];
    self.isReload = YES;
}

- (void)dataSourceDidLoad {
    [self endRefresh];
}

- (void)dataSourceDidError {
    [self endRefresh];
}

- (BOOL)dataSourceIsEmpty {
    return NO;
}

- (void)beginRefresh {
    self.reloading = YES;
}

- (void)endRefresh {
    self.reloading = NO;
}

#pragma mark - Convenience
// DEPRECATED
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
