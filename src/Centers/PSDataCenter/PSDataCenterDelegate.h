/*
 *  PSDataCenterDelegate.h
 *  PhotoTime
 *
 *  Created by Peter Shih on 2/22/11.
 *  Copyright 2011 Seven Minute Labs. All rights reserved.
 *
 */

@protocol PSDataCenterDelegate <NSObject>

@optional
- (void)dataCenterDidFinishWithResponse:(id)response andUserInfo:(NSDictionary *)userInfo;
- (void)dataCenterDidFailWithError:(NSError *)error andUserInfo:(NSDictionary *)userInfo;

@end
