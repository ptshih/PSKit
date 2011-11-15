//
//  PSSearchCenter.h
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 7/12/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSObject.h"

@interface PSSearchCenter : PSObject {
  NSMutableDictionary *_terms;
}

+ (id)defaultCenter;

- (NSArray *)searchResultsForTerm:(NSString *)term inContainer:(NSString *)container;
- (BOOL)addTerm:(NSString *)term inContainer:(NSString *)container;
- (void)resetTerms;

@end
