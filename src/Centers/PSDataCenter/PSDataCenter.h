//
//  PSDataCenter.h
//  PhotoTime
//
//  Created by Peter Shih on 2/22/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSObject.h"
#import "PSDataCenterDelegate.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JSONKit.h"
#import "PSNetworkQueue.h"
#import "NetworkConstants.h"

#define SINCE_SAFETY_NET 300 // 5 minutes

@interface PSDataCenter : PSObject <PSDataCenterDelegate> {
  id <PSDataCenterDelegate> _delegate;
}

@property (nonatomic, assign) id <PSDataCenterDelegate> delegate;

/**
 Shared instance is smart and will automatically allocate for subclasses
 */
+ (id)defaultCenter;

- (NSMutableData *)buildRequestParamsData:(NSDictionary *)params;
- (NSString *)buildRequestParamsString:(NSDictionary *)params;

/**
 Send network operation to server (GET/POST)
 
 By default this will set all required headers
 
 url - required defined in Constants.h
 method - optional (defaults to GET) defined in Constants.h (should be GET or POST)
 headers - optional
 params - optional
 */
- (void)sendRequestWithURL:(NSURL *)url andMethod:(NSString *)method andHeaders:(NSDictionary *)headers andParams:(NSDictionary *)params andUserInfo:(NSDictionary *)userInfo;

/**
 Send network request with an attachment, FORM DATA POST
 */
- (void)sendFormRequestWithURL:(NSURL *)url andHeaders:(NSDictionary *)headers andParams:(NSDictionary *)params andFile:(NSDictionary *)file andUserInfo:(NSDictionary *)userInfo;

- (void)sendFacebookBatchRequestWithParams:(NSDictionary *)params andUserInfo:(NSDictionary *)userInfo;

// Subclass should Implement AND call super's implementation
- (void)dataCenterRequestFinished:(ASIHTTPRequest *)request;
- (void)dataCenterRequestFailed:(ASIHTTPRequest *)request;

@end
