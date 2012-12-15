//
//  PSGridViewCell.m
//  PSKit
//
//  Created by Peter Shih on 12/14/12.
//
//

#import "PSGridViewCell.h"

@interface PSGridViewCell ()

@property (nonatomic, strong) PSCachedImageView *imageView;

@end

@implementation PSGridViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.multipleTouchEnabled = YES;
        
        self.imageView = [[PSCachedImageView alloc] initWithFrame:CGRectZero];
        self.imageView.loadingColor = RGBACOLOR(60, 60, 60, 1.0);
        self.imageView.loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        self.imageView.shouldAnimate = YES;
        self.imageView.clipsToBounds = YES;
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)prepareForReuse {
    [self.imageView prepareForReuse];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Photo
    self.imageView.frame = self.bounds;
}

- (void)loadImage:(UIImage *)image {
    self.imageView.image = image;
}

@end
