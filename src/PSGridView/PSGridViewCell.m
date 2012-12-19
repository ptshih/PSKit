//
//  PSGridViewCell.m
//  PSKit
//
//  Created by Peter Shih on 12/14/12.
//
//

#import "PSGridViewCell.h"

@interface PSGridViewCell ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) PSCachedImageView *imageView;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong, readwrite) NSDictionary *content;

@end

@implementation PSGridViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        self.multipleTouchEnabled = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleSize;
//        self.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
//        self.backgroundColor = RGBCOLOR(230, 230, 230);
        
        self.contentView = [[UIView alloc] initWithFrame:self.bounds];
        self.contentView.autoresizingMask = self.autoresizingMask;
        self.contentView.userInteractionEnabled = NO;
        self.contentView.backgroundColor = RGBCOLOR(222, 222, 222);
        [self addSubview:self.contentView];
        
        self.content = @{};
        
//        self.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1.0].CGColor;
//        self.layer.borderWidth = 1.0;
    }
    return self;
}

- (void)prepareForReuse {
    [self.imageView prepareForReuse];
    self.textLabel.text = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.textLabel) {
        self.textLabel.frame = CGRectInset(self.contentView.bounds, 16.0, 16.0);
    } else if (self.imageView) {
        self.imageView.frame = self.contentView.bounds;
    }
}

#pragma mark - Setup

- (void)setupImageView {
    if (!self.imageView) {
        self.imageView = [[PSCachedImageView alloc] initWithFrame:CGRectZero];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleSize;
        self.imageView.loadingColor = RGBACOLOR(60, 60, 60, 1.0);
        self.imageView.loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        self.imageView.shouldAnimate = YES;
        self.imageView.clipsToBounds = YES;
        [self.contentView addSubview:self.imageView];
    }
}

#pragma mark - Load

- (void)prepareLoad {
    if (self.imageView) {
        [self.imageView removeFromSuperview];
        self.imageView = nil;
    }
    
    if (self.textLabel) {
        [self.textLabel removeFromSuperview];
        self.textLabel = nil;
    }
    
    self.contentView.backgroundColor = [UIColor colorWithRGBHex:0xefefef];
}

- (void)loadContent:(NSDictionary *)content {
    self.content = content;
    // Update UI
    
    [self prepareLoad];
    
    if ([[self.content objectForKey:@"type"] isEqualToString:@"text"]) {
        NSString *text = [self.content objectForKey:@"text"];
        [self loadText:text];
    } else if ([[self.content objectForKey:@"type"] isEqualToString:@"image"]) {
        NSString *href = [self.content objectForKey:@"href"];
        [self loadImageAtURL:[NSURL URLWithString:href]];
    }
}

- (void)loadImage:(UIImage *)image {
    [self prepareLoad];
    [self setupImageView];
    
    self.imageView.image = image;
    [self.imageView.loadingIndicator stopAnimating];
    
    // Photo
    self.imageView.frame = self.contentView.bounds;
}

- (void)loadImageAtURL:(NSURL *)URL {
    if (!self.imageView) {
        self.imageView = [[PSCachedImageView alloc] initWithFrame:CGRectZero];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleSize;
        self.imageView.loadingColor = RGBACOLOR(60, 60, 60, 1.0);
        self.imageView.loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        self.imageView.shouldAnimate = YES;
        self.imageView.clipsToBounds = YES;
        [self.contentView addSubview:self.imageView];
    }
    
    self.imageView.originalURL = URL;
    [self.imageView loadImageWithURL:URL cacheType:PSURLCacheTypePermanent];
}

- (void)loadText:(NSString *)text {
    if (!self.textLabel) {
        self.textLabel = [UILabel labelWithStyle:@"cellTitleDarkLabel"];
        self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleSize;
        self.textLabel.font = [UIFont fontWithName:@"ProximaNovaCond-Semibold" size:64.0];
        self.textLabel.minimumFontSize = 12.0;
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.textLabel.numberOfLines = 1;
        self.textLabel.textAlignment = UITextAlignmentCenter;
        //        self.textLabel.backgroundColor = [UIColor lightGrayColor];
        self.textLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        [self.contentView addSubview:self.textLabel];
    }
    
    self.textLabel.text = text;
}

- (void)loadColor:(UIColor *)color {
    [self prepareLoad];
    self.contentView.backgroundColor = color;
}

@end
