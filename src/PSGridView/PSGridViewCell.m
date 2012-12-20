//
//  PSGridViewCell.m
//  PSKit
//
//  Created by Peter Shih on 12/14/12.
//
//

#import "PSGridViewCell.h"

#pragma mark - Gesture Recognizer

// This is just so we know that we sent this tap gesture recognizer in the delegate

@interface PSGridViewTapGestureRecognizer : UITapGestureRecognizer
@end

@implementation PSGridViewTapGestureRecognizer
@end


@interface PSGridViewLongPressGestureRecognizer : UILongPressGestureRecognizer
@end

@implementation PSGridViewLongPressGestureRecognizer
@end




@interface PSGridViewCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) PSCachedImageView *imageView;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong, readwrite) NSDictionary *content;

@end

@implementation PSGridViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = NO;
//        self.autoresizingMask = UIViewAutoresizingFlexibleSize;
//        self.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
//        self.backgroundColor = RGBCOLOR(230, 230, 230);
        
        self.contentView = [[UIView alloc] initWithFrame:self.bounds];
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleSize;
        self.contentView.userInteractionEnabled = NO;
        self.contentView.backgroundColor = RGBCOLOR(222, 222, 222);
        [self addSubview:self.contentView];
        
        self.content = @{};
        
//        self.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1.0].CGColor;
//        self.layer.borderWidth = 1.0;
        
        // Setup gesture recognizer
        PSGridViewTapGestureRecognizer *gr = [[PSGridViewTapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapCell:)];
        gr.delegate = self;
        [self addGestureRecognizer:gr];
    
        PSGridViewLongPressGestureRecognizer *lpgr = [[PSGridViewLongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressCell:)];
        lpgr.delegate = self;
        [self addGestureRecognizer:lpgr];
    }
    return self;
}

#pragma mark - Gesture Recognizer

- (void)didTapCell:(UITapGestureRecognizer *)gestureRecognizer {
    NSLog(@"tap: %d", gestureRecognizer.state);
    if (self.delegate && [self.delegate respondsToSelector:@selector(gridViewCell:didTapWithWithState:)]) {
        [self.delegate gridViewCell:self didTapWithWithState:gestureRecognizer.state];
    }
}

- (void)didLongPressCell:(UILongPressGestureRecognizer *)gestureRecognizer {
    NSLog(@"lp: %d", gestureRecognizer.state);
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(gridViewCell:didLongPressWithState:)]) {
            [self.delegate gridViewCell:self didLongPressWithState:gestureRecognizer.state];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

#pragma mark -

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
    } else if ([[self.content objectForKey:@"type"] isEqualToString:@"photo"]) {
        [self loadImage:[self.content objectForKey:@"photo"]];
    } else if([[self.content objectForKey:@"type"] isEqualToString:@"color"]) {
        [self loadColor:[self.content objectForKey:@"color"]];
    }
    
    [self setNeedsLayout];
}

- (void)loadImage:(UIImage *)image {
    if (!self.imageView) {
        self.imageView = [[PSCachedImageView alloc] initWithFrame:CGRectZero];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleSize;
        self.imageView.loadingColor = RGBACOLOR(60, 60, 60, 1.0);
        self.imageView.loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        self.imageView.shouldAnimate = YES;
        self.imageView.clipsToBounds = YES;
        [self.contentView addSubview:self.imageView];
    }
    [self.imageView.loadingIndicator stopAnimating];
    self.imageView.image = image;
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
    self.contentView.backgroundColor = color;
}

#pragma mark - Touches

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//}
//
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
//}

@end
