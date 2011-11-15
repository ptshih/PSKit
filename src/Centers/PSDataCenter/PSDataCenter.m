//
//  PSDataCenter.m
//  PhotoTime
//
//  Created by Peter Shih on 2/22/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import "PSDataCenter.h"

@interface PSDataCenter (Private)

- (id)sanitizeResponse:(NSData *)responseData;
- (NSDictionary *)sanitizeDictionary:(NSDictionary *)dictionary forKeys:(NSArray *)keys;
- (NSArray *)sanitizeArray:(NSArray *)array;

@end

@implementation PSDataCenter

@synthesize delegate = _delegate;

// SUBCLASSES MUST IMPLEMENT
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
  }
  return self;
}

- (void)dealloc {
  [super dealloc];
}

#pragma mark -
#pragma mark Serialize
- (id)sanitizeResponse:(NSData *)responseData {
  // Serialize the response
  id rawResponse = [responseData objectFromJSONData];
  id response = nil;
  
  // We should sanitize the response
  if ([rawResponse isKindOfClass:[NSArray class]]) {
    response = [self sanitizeArray:rawResponse];
  } else if ([rawResponse isKindOfClass:[NSDictionary class]]) {
    response = [self sanitizeDictionary:rawResponse forKeys:[rawResponse allKeys]];
  } else {
    // Throw an assertion, why is it not a dictionary or an array???
    DLog(@"### ERROR IN DATA CENTER, RESPONSE IS NEITHER AN ARRAY NOR A DICTIONARY");
  }
  
  if (response) {
    return response;
  } else {
    return nil;
  }
}

#pragma mark -
#pragma mark Send Operation
- (void)sendFacebookBatchRequestWithParams:(NSDictionary *)params andUserInfo:(NSDictionary *)userInfo {
  // Read any optional params
  NSMutableDictionary *requestParams = [NSMutableDictionary dictionaryWithDictionary:params];
  
  // Send access_token as a parameter if exists
  NSString *accessToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"facebookAccessToken"];
  if (accessToken) {
    [requestParams setValue:accessToken forKey:@"access_token"];
  }
  
  ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:FB_GRAPH]];
  request.requestMethod = @"POST";
  
  // Allow GZIP
  request.allowCompressedResponse = YES;
  
  // Request userInfo
  request.userInfo = userInfo;
  
  // POST parameters
  request.postBody = [self buildRequestParamsData:requestParams];
  request.postLength = [request.postBody length];
  
  [request addRequestHeader:@"Accept" value:@"application/json"];
  
  // Request Completion
  [request setDelegate:self];
  [request setDidFinishSelector:@selector(dataCenterRequestFinished:)];
  [request setDidFailSelector:@selector(dataCenterRequestFailed:)];

  [request startAsynchronous];
}

- (void)sendRequestWithURL:(NSURL *)url andMethod:(NSString *)method andHeaders:(NSDictionary *)headers andParams:(NSDictionary *)params andUserInfo:(NSDictionary *)userInfo {
  // Read any optional params
  NSMutableDictionary *requestParams = [NSMutableDictionary dictionaryWithDictionary:params];
  
  // Send access_token as a parameter if exists
  NSString *accessToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"facebookAccessToken"];
  if (accessToken) {
    [requestParams setValue:accessToken forKey:@"access_token"];
  }
  
  // GET parameters
  if ([method isEqualToString:GET]) {
    url = [NSURL URLWithString:[NSString stringWithFormat:@"?%@", [self buildRequestParamsString:requestParams]] relativeToURL:url];
  }
  
  ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
  request.requestMethod = method;
  
  request.numberOfTimesToRetryOnTimeout = 3;
  
  // Allow GZIP
  request.allowCompressedResponse = YES;
  
  // Request userInfo
  request.userInfo = userInfo;
  
  // POST parameters
  if ([method isEqualToString:POST]) {
    request.postBody = [self buildRequestParamsData:requestParams];
    request.postLength = [request.postBody length];
  }
  
  // Build Custom Headers if exists
  if (headers) {
    NSArray *allKeys = [headers allKeys];
    NSArray *allValues = [headers allValues];
    for (int i = 0; i < [headers count]; i++) {
      // NOTE: should probably type transform coerce in the future
      [request addRequestHeader:[allKeys objectAtIndex:i] value:[allValues objectAtIndex:i]];
    }
  }
  
  // HTTP Accept
  //  [request addRequestHeader:@"Content-Type" value:@"application/json"];
  [request addRequestHeader:@"Accept" value:@"application/json"];
  
  // Request Completion
  [request setDelegate:self];
  [request setDidFinishSelector:@selector(dataCenterRequestFinished:)];
  [request setDidFailSelector:@selector(dataCenterRequestFailed:)];
  
  // Start the Request
  [request startAsynchronous];
}

- (void)sendFormRequestWithURL:(NSURL *)url andHeaders:(NSDictionary *)headers andParams:(NSDictionary *)params andFile:(NSDictionary *)file andUserInfo:(NSDictionary *)userInfo {
  NSMutableDictionary *requestParams = [NSMutableDictionary dictionaryWithDictionary:params];
  
  // Send access_token as a parameter if exists
  NSString *accessToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"facebookAccessToken"];
  if (accessToken) {
    [requestParams setValue:accessToken forKey:@"access_token"];
  }
  
  ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
  request.requestMethod = POST;
  
  // Allow GZIP
  request.allowCompressedResponse = YES;
  
  // Request userInfo
  request.userInfo = userInfo;
  
  // POST body
  // Build Params if exists
  if (requestParams) {
    NSArray *allKeys = [requestParams allKeys];
    NSArray *allValues = [requestParams allValues];
    for (int i = 0; i < [requestParams count]; i++) {
      [request setPostValue:[allValues objectAtIndex:i] forKey:[allKeys objectAtIndex:i]];
    }
  }
  
  // POST file
  [request setData:[file objectForKey:@"fileData"] withFileName:[file objectForKey:@"fileName"] andContentType:[file objectForKey:@"fileContentType"] forKey:[file objectForKey:@"fileKey"]];

  // Build Custom Headers if exists
  if (headers) {
    NSArray *allKeys = [headers allKeys];
    NSArray *allValues = [headers allValues];
    for (int i = 0; i < [headers count]; i++) {
      // NOTE: should probably type transform coerce in the future
      [request addRequestHeader:[allKeys objectAtIndex:i] value:[allValues objectAtIndex:i]];
    }
  }
  
  // HTTP Accept
  //  [request addRequestHeader:@"Content-Type" value:@"application/json"];
  [request addRequestHeader:@"Accept" value:@"application/json"];
  
  // Request Completion
  [request setDelegate:self];
  [request setDidFinishSelector:@selector(dataCenterRequestFinished:)];
  [request setDidFailSelector:@selector(dataCenterRequestFailed:)];
  
  // Progress
//  [request setUploadProgressDelegate:[PSProgressCenter defaultCenter]];
//  [[PSProgressCenter defaultCenter] setMessage:@"Uploading Photo..."];
  
  // Start the Request
  [request startAsynchronous];
}

#pragma mark -
#pragma mark Request Finished/Failed
- (void)dataCenterRequestFinished:(ASIHTTPRequest *)request {
  // subclass should implement
  
}

- (void)dataCenterRequestFailed:(ASIHTTPRequest *)request {
  // subclass should implement
  DLog(@"Request failed with error: %@", [[request error] localizedDescription]);
}

#pragma mark -
#pragma mark PSParserStackDelegate
- (void)parseFinishedWithResponse:(id)response andUserInfo:(NSDictionary *)userInfo {
  // subclass should implement
}

#pragma mark -
#pragma mark Private Convenience Methods
- (NSArray *)sanitizeArray:(NSArray *)array {
  NSMutableArray *sanitizedArray = [NSMutableArray array];
  
  // Loop thru all dictionaries in the array
  NSDictionary *sanitizedDictionary = nil;
  for (id value in array) {
    if ([value isKindOfClass:[NSDictionary class]]) {
      sanitizedDictionary = [self sanitizeDictionary:value forKeys:[value allKeys]];
      [sanitizedArray addObject:sanitizedDictionary];
    } else {
      [sanitizedArray addObject:value];
    }
  }
  
  return sanitizedArray;
}

- (NSDictionary *)sanitizeDictionary:(NSDictionary *)dictionary forKeys:(NSArray *)keys {
  NSMutableDictionary *sanitizedDictionary = [NSMutableDictionary dictionary];
  
  // Loop thru all keys we expect to get and remove any keys with nil values
  NSString *value = nil;
  for (NSString *key in keys) {
    value = [dictionary valueForKey:key];
    
    if ([value notNil]) {
      if ([value isKindOfClass:[NSArray class]]) {
        [sanitizedDictionary setValue:[self sanitizeArray:(NSArray *)value] forKey:key];
      } else if ([value isKindOfClass:[NSDictionary class]]) {
        [sanitizedDictionary setValue:[self sanitizeDictionary:(NSDictionary *)value forKeys:[(NSDictionary *)value allKeys]] forKey:key];
      } else {
        [sanitizedDictionary setValue:value forKey:key];
      }
    }
  }
  
  return sanitizedDictionary;
}

- (NSString *)buildRequestParamsString:(NSDictionary *)params {
  if (!params) return nil;
  
  NSMutableString *encodedParameterPairs = [NSMutableString string];
  
  NSArray *allKeys = [params allKeys];
  NSArray *allValues = [params allValues];
  
  for (int i = 0; i < [params count]; i++) {
    NSString *key = [[NSString stringWithFormat:@"%@", [allKeys objectAtIndex:i]] stringByURLEncoding];
    NSString *value = [[NSString stringWithFormat:@"%@", [allValues objectAtIndex:i]] stringByURLEncoding];
    [encodedParameterPairs appendFormat:@"%@=%@", key, value];
    if (i < [params count] - 1) {
      [encodedParameterPairs appendString:@"&"];
    }
  }
  
  return encodedParameterPairs;
}

- (NSMutableData *)buildRequestParamsData:(NSDictionary *)params {
  return [NSMutableData dataWithData:[[self buildRequestParamsString:params] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
}

@end
