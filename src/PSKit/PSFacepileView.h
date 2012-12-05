//
//  PSFacepileView.h
//  PSKit
//
//  Created by Peter Shih on 5/15/12.
//  Copyright (c) 2012 Peter Shih. All rights reserved.
//

#import "PSView.h"

@interface PSFacepileView : PSView

- (void)prepareForReuse;
- (void)loadWithFaces:(NSArray *)faces shouldShowNames:(BOOL)shouldShowNames;
+ (CGFloat)heightWithFaces:(NSArray *)faces shouldShowNames:(BOOL)shouldShowNames;
+ (CGFloat)widthWithFaces:(NSArray *)faces shouldShowNames:(BOOL)shouldShowNames;

@end
