//
//  PSSearchCenter.h
//  PSKit
//
//  Created by Peter Shih on 7/12/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PS_SEARCH_CENTER_PLIST @"pssearchcenter.plist"

@interface PSSearchCenter : NSObject {
  NSMutableDictionary *_terms;
}

+ (id)defaultCenter;

- (NSArray *)searchResultsForTerm:(NSString *)term inContainer:(NSString *)container;
- (BOOL)addTerm:(NSString *)term inContainer:(NSString *)container;
- (void)resetTerms;

@end
