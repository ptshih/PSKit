//
//  PSDataCenter.h
//  PhotoTime
//
//  Created by Peter Shih on 2/22/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSDataCenterDelegate.h"

@interface PSDataCenter : PSObject <PSDataCenterDelegate> {
  id <PSDataCenterDelegate> _delegate;
}

@property (nonatomic, assign) id <PSDataCenterDelegate> delegate;

+ (id)defaultCenter;

- (NSMutableData *)buildRequestParamsData:(NSDictionary *)params;
- (NSString *)buildRequestParamsString:(NSDictionary *)params;

@end
