//
//  PSNewspaperCell.m
//  PSKit
//
//  Created by Peter Shih on 7/3/12.
//  Copyright (c) 2012 Peter Shih. All rights reserved.
//

#import "PSNewspaperCell.h"

@interface PSNewspaperCell ()


@end


@implementation PSNewspaperCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.cellType = PSNewspaperCellSmall;
        self.cellOrientation = PSNewspaperCellPortrait;
        
        self.imageView = [[PSCachedImageView alloc] initWithFrame:CGRectZero];
        self.imageView.clipsToBounds = YES;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.imageView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:self.titleLabel];
        
        self.textView = [[PSNewspaperTextView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.textView];
    }
    return self;
}

- (void)prepareForReuse {
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)fillCellWithObject:(id)object {
    self.object = object;
}

@end
