//
//  PSFacepileView.h
//  Lunchbox
//
//  Created by Peter Shih on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSView.h"

@interface PSFacepileView : PSView

- (void)prepareForReuse;
- (void)loadWithFaces:(NSArray *)faces;
+ (CGFloat)heightWithFaces:(NSArray *)faces;
+ (CGFloat)widthWithFaces:(NSArray *)faces;

@end
