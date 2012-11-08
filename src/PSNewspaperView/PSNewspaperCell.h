//
//  PSNewspaperCell.h
//  PSKit
//
//  Created by Peter Shih on 7/3/12.
//  Copyright (c) 2012 Peter Shih. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSNewspaperTextView.h"

enum {
    PSNewspaperCellSmall = 0,
    PSNewspaperCellLarge = 1
};
typedef uint32_t PSNewspaperCellType;

enum {
    PSNewspaperCellPortrait = 0,
    PSNewspaperCellLandscape = 1
};
typedef uint32_t PSNewspaperCellOrientation;

@interface PSNewspaperCell : UIView

@property (nonatomic, copy) NSDictionary *object;
@property (nonatomic, assign) PSNewspaperCellType cellType;
@property (nonatomic, assign) PSNewspaperCellOrientation cellOrientation;

@property (nonatomic, strong) PSCachedImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) PSNewspaperTextView *textView;

- (id)initWithFrame:(CGRect)frame;

- (void)prepareForReuse;
- (void)fillCellWithObject:(id)object;

@end
