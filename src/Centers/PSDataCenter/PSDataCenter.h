//
//  PSDataCenter.h
//  PhotoTime
//
//  Created by Peter Shih on 2/22/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSDataCenterDelegate.h"

#define SINCE_SAFETY_NET 300 // 5 minutes

@interface PSDataCenter : PSObject <PSDataCenterDelegate> {
  id <PSDataCenterDelegate> _delegate;
}

@property (nonatomic, assign) id <PSDataCenterDelegate> delegate;

+ (id)defaultCenter;

- (NSMutableData *)buildRequestParamsData:(NSDictionary *)params;
- (NSString *)buildRequestParamsString:(NSDictionary *)params;

@end
