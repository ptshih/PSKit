//
//  PSGridViewCell.m
//  PSKit
//
//  Created by Peter Shih on 12/14/12.
//
//

#import "PSGridViewCell.h"

#import "PSYouTubeView.h"

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




@interface PSGridViewCell () <UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UIView *highlightView;
@property (nonatomic, strong) UIScrollView *imageScrollView;
@property (nonatomic, strong) PSCachedImageView *imageView;
@property (nonatomic, strong) PSYouTubeView *ytView;
@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation PSGridViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = NO;
        self.clipsToBounds = YES;
//        self.autoresizingMask = UIViewAutoresizingFlexibleSize;
//        self.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
        self.backgroundColor = RGBCOLOR(160, 160, 160);
        
        
        self.content = @{};
        
        
        // Content
        self.imageScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.imageScrollView.autoresizingMask = UIViewAutoresizingFlexibleSize;
        self.imageScrollView.userInteractionEnabled = NO;
        self.imageScrollView.delegate = self;
        self.imageScrollView.scrollEnabled = YES;
        self.imageScrollView.minimumZoomScale = 1.0;
        self.imageScrollView.maximumZoomScale = 2.0;
        self.imageScrollView.showsHorizontalScrollIndicator = NO;
        self.imageScrollView.showsVerticalScrollIndicator = NO;
        self.imageScrollView.hidden = YES;
        [self addSubview:self.imageScrollView];
        
        self.imageView = [[PSCachedImageView alloc] initWithFrame:self.imageScrollView.bounds];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleSize;
        self.imageView.loadingColor = RGBACOLOR(60, 60, 60, 1.0);
        self.imageView.loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        self.imageView.shouldAnimate = YES;
        self.imageView.clipsToBounds = YES;
        [self.imageScrollView addSubview:self.imageView];
        
        self.textLabel = [UILabel labelWithStyle:@"cellTitleDarkLabel"];
        self.textLabel.userInteractionEnabled = NO;
        self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleSize;
        self.textLabel.font = [UIFont fontWithName:@"ProximaNovaCond-Semibold" size:64.0];
        self.textLabel.minimumFontSize = 12.0;
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.textLabel.numberOfLines = 1;
        self.textLabel.textAlignment = UITextAlignmentCenter;
        //        self.textLabel.backgroundColor = [UIColor lightGrayColor];
        self.textLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        self.textLabel.hidden = YES;
        [self addSubview:self.textLabel];
        
        // Video
        self.ytView = [[PSYouTubeView alloc] initWithFrame:self.bounds];
        self.ytView.autoresizingMask = UIViewAutoresizingFlexibleSize;
        self.ytView.hidden = YES;
        [self addSubview:self.ytView];
        
        
        // Highlight
        self.highlightView = [[UIView alloc] initWithFrame:self.bounds];
        self.highlightView.autoresizingMask = UIViewAutoresizingFlexibleSize;
        self.highlightView.userInteractionEnabled = NO;
        self.highlightView.backgroundColor = RGBACOLOR(0, 0, 0, 0.5);
        self.highlightView.alpha = 0.0;
        [self addSubview:self.highlightView];
        
//        self.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1.0].CGColor;
//        self.layer.borderWidth = 1.0;
        
        // Setup gesture recognizer
//        PSGridViewTapGestureRecognizer *gr = [[PSGridViewTapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapCell:)];
//        gr.delegate = self;
//        [self addGestureRecognizer:gr];
    
//        PSGridViewLongPressGestureRecognizer *lpgr = [[PSGridViewLongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressCell:)];
//        lpgr.delegate = self;
//        [self addGestureRecognizer:lpgr];
    }
    return self;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)centerSubview:(UIView *)subView forScrollView:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

- (void)showHighlight {
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.highlightView.alpha = 1.0;
    } completion:^(BOOL finished) {
    }];
}

- (void)hideHighlight {
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.highlightView.alpha = 0.0;
    } completion:^(BOOL finished) {
    }];
}

- (void)enableVideoTouch {
    self.ytView.userInteractionEnabled = YES;
}
- (void)disableVideoTouch {
    self.ytView.userInteractionEnabled = NO;
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

- (void)didPanCell:(UIPanGestureRecognizer *)gr {
    CGPoint translatedPoint = [gr translationInView:self];
    [gr setTranslation:CGPointZero inView:self];
    self.imageView.center = CGPointMake(self.imageView.center.x + translatedPoint.x, self.imageView.center.y + translatedPoint.y);
}

- (void)didPinchCell:(UIPinchGestureRecognizer *)gr {
//    self.imageView.
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
    
    if (self.textLabel.hidden == NO) {
        self.textLabel.frame = CGRectInset(self.bounds, 16.0, 16.0);
    } else if (self.imageScrollView.hidden == NO) {
        self.imageScrollView.frame = self.bounds;
        self.imageView.frame = self.imageScrollView.bounds;
        
//        CGFloat objectWidth = self.imageView.image.size.width;
//        CGFloat objectHeight = self.imageView.image.size.height;
//        CGFloat scaledHeight = floorf(objectHeight / (objectWidth / self.imageScrollView.width));
//        
//        self.imageView.frame = CGRectMake(0, 0, self.imageScrollView.width, scaledHeight);
//        self.imageScrollView.contentSize = self.imageView.frame.size;
//        [self centerSubview:self.imageView forScrollView:self.imageScrollView];
    } else if (self.ytView.hidden == NO) {
        self.ytView.frame = self.bounds;
    }
}

#pragma mark - Load

- (void)prepareLoad {
    self.imageScrollView.hidden = YES;
    self.textLabel.hidden = YES;
    self.ytView.hidden = YES;
    
    self.backgroundColor = [UIColor colorWithRGBHex:0xefefef];
}

- (void)loadContent {
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
    } else if ([[self.content objectForKey:@"type"] isEqualToString:@"color"]) {
        [self loadColor:[self.content objectForKey:@"color"]];
    } else if ([[self.content objectForKey:@"type"] isEqualToString:@"video"]) {
        [self loadVideo:[self.content objectForKey:@"yid"]];
    }
    
    [self setNeedsLayout];
}

- (void)loadVideo:(NSString *)yid {
    if (self.ytView.userInteractionEnabled) {
        self.ytView.hidden = NO;
        self.ytView.frame = self.bounds;
        NSString *src = [NSString stringWithFormat:@"http://www.youtube.com/embed/%@",yid];
        [self.ytView loadYouTubeWithSource:src contentSize:self.bounds.size];
    } else {
        NSString *src = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/hqdefault.jpg", yid];
        [self loadImageAtURL:[NSURL URLWithString:src]];
    }
}

- (void)loadImage:(UIImage *)image {
//        UIPanGestureRecognizer *pangr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanCell:)];
//        [self.imageView addGestureRecognizer:pangr];
//        
//        UIPinchGestureRecognizer *pinchgr = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didPinchCell:)];
//        [self.imageView addGestureRecognizer:pinchgr];
    
    self.imageScrollView.hidden = NO;
    [self.imageView.loadingIndicator stopAnimating];
    self.imageView.image = image;
}

- (void)loadImageAtURL:(NSURL *)URL {
    self.imageScrollView.hidden = NO;
    self.imageView.originalURL = URL;
    [self.imageView loadImageWithURL:URL cacheType:PSURLCacheTypePermanent];
}

- (void)loadText:(NSString *)text {
    self.textLabel.hidden = NO;
    
    self.textLabel.text = text;
}

- (void)loadColor:(UIColor *)color {
    self.backgroundColor = color;
}

#pragma mark - Cell Actions

// Remove cell
- (void)removeCell {
    PSGridViewCell *cell = self;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        cell.alpha = 0.0;
    } completion:^(BOOL finished) {
        [cell removeFromSuperview];
        [self.cells removeObject:cell];
    }];
}

- (void)editCell {
    // TODO
    PSGridViewCell *cell = self;
    
    [UIActionSheet actionSheetWithTitle:@"Add/Edit Content" message:nil destructiveButtonTitle:nil buttons:@[@"Text", @"Image URL", @"Video", @"Photo", @"Remove"] showInView:self onDismiss:^(int buttonIndex, NSString *textInput) {
        
        // Load with configuration
        switch (buttonIndex) {
            case 0: {
                [UIAlertView alertViewWithTitle:@"Enter Text" style:UIAlertViewStylePlainTextInput message:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Ok"] onDismiss:^(int buttonIndex, NSString *textInput){
                    NSLog(@"%@", textInput);
                    
                    if (textInput.length > 0) {
                        NSDictionary *content = @{@"type" : @"text", @"text": textInput};
                        cell.content = content;
                        [cell loadContent];
                    }
                } onCancel:^{
                }];
                break;
            }
            case 1: {
                [UIAlertView alertViewWithTitle:@"Image" style:UIAlertViewStylePlainTextInput message:@"URL" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Ok"] onDismiss:^(int buttonIndex, NSString *textInput){
                    NSLog(@"%@", textInput);
                    
                    if (textInput.length > 0) {
                        NSDictionary *content = @{@"type" : @"image", @"href": textInput};
                        cell.content = content;
                        [cell loadContent];
                    }
                } onCancel:^{
                }];
                break;
            }
            case 2: {
                NSDictionary *content = @{@"type" : @"video", @"yid": @"9bZkp7q19f0"};
                cell.content = content;
                [cell disableVideoTouch];
                [cell loadContent];
                break;
            }
            case 3: {
//                [UIActionSheet photoPickerWithTitle:@"Pick a Photo" showInView:self.parentViewController.view presentVC:self.parentViewController onPhotoPicked:^(UIImage *chosenImage) {
//                    if (chosenImage) {
//                        NSDictionary *content = @{@"type" : @"photo", @"photo": chosenImage};
//                        cell.content = content;
//                        [cell loadContent];
//                    }
//                } onCancel:^{
//                }];
                break;
            }
            case 4: {
                // remove cell
                [self removeCell];
                break;
            }
            default:
                break;
        }
    } onCancel:^{
    }];
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];

    UITouch *touch = [touches anyObject];
    
    if (touch.tapCount == 1) {
        [self editCell];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
}

@end
