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
isReload = _isReload;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.requestQueue = [[NSOperationQueue alloc] init];
        self.requestQueue.maxConcurrentOperationCount = 1;
        self.reloading = NO;
        self.isReload = NO;
    }
    return self;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setupSubviews {
    [super setupSubviews];
}

#pragma mark - PSStateMachine
// Data Source
- (void)loadDataSource {
    ASSERT_MAIN_THREAD;
    [self beginRefresh];
    self.isReload = NO;
}

- (void)reloadDataSource {
    ASSERT_MAIN_THREAD;
    [self beginRefresh];
    self.isReload = YES;
}

- (void)dataSourceDidLoad {
    ASSERT_MAIN_THREAD;
    [self endRefresh];
}

- (void)dataSourceDidError {
    ASSERT_MAIN_THREAD;
    [self endRefresh];
}

- (BOOL)dataSourceIsEmpty {
    return NO;
}

- (void)beginRefresh {
    ASSERT_MAIN_THREAD;
    self.reloading = YES;
}

- (void)endRefresh {
    ASSERT_MAIN_THREAD;
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
        results = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return results;
}



@end
