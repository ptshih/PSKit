//
//  PSGridViewCell.m
//  PSKit
//
//  Created by Peter Shih on 12/14/12.
//
//

#import "PSGridViewCell.h"

#import "PSYouTubeView.h"

// TODO
#import "AppDelegate.h"

#import "ImagePickerViewController.h"
#import "FacebookAlbumViewController.h"

@interface PSGridViewCell () <UIScrollViewDelegate, ImagePickerDelegate>

@property (nonatomic, strong) UIPopoverController *pc;

@property (nonatomic, strong) UIView *highlightView;
@property (nonatomic, strong) UIScrollView *imageScrollView;
@property (nonatomic, strong) PSCachedImageView *imageView;
@property (nonatomic, strong) PSYouTubeView *ytView;
@property (nonatomic, strong) UILabel *textLabel;

// Touch
@property (nonatomic, assign) CGPoint originalTouchPoint;
@property (nonatomic, assign) BOOL touchDidMove;

@end

@implementation PSGridViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = NO;
        self.clipsToBounds = YES;
        
        self.touchDidMove = NO;
        
        // Models
        self.content = @{};
        
        self.backgroundColor = [UIColor colorWithWhite:0.99 alpha:0.8];
        
        
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
        self.textLabel.numberOfLines = 0;
        self.textLabel.textAlignment = UITextAlignmentCenter;
//        self.textLabel.backgroundColor = [UIColor greenColor];
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
    }
    return self;
}

- (void)fitText {
    // Loop and try to fit the text in the rect
    CGFloat fontSize = 96.0;
    CGFloat cellWidth = self.textLabel.width;
    CGFloat cellHeight = self.textLabel.height;
    
    while (1) {
        self.textLabel.font = [UIFont fontWithName:@"ProximaNovaCond-Semibold" size:fontSize];
        CGSize size = [self.textLabel sizeForLabelInWidth:cellWidth];
        if (size.height <= cellHeight) {
            self.textLabel.width = cellWidth;
            self.textLabel.height = cellHeight;
            break;
        } else {
            fontSize--;
        }
    }
    NSLog(@"%@", self.textLabel);
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

//- (void)didTapCell:(UITapGestureRecognizer *)gestureRecognizer {
//    NSLog(@"tap: %d", gestureRecognizer.state);
//    if (self.delegate && [self.delegate respondsToSelector:@selector(gridViewCell:didTapWithWithState:)]) {
//        [self.delegate gridViewCell:self didTapWithWithState:gestureRecognizer.state];
//    }
//}
//
//- (void)didLongPressCell:(UILongPressGestureRecognizer *)gestureRecognizer {
//    NSLog(@"lp: %d", gestureRecognizer.state);
//    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
//        if (self.delegate && [self.delegate respondsToSelector:@selector(gridViewCell:didLongPressWithState:)]) {
//            [self.delegate gridViewCell:self didLongPressWithState:gestureRecognizer.state];
//        }
//    }
//}
//
//- (void)didPanCell:(UIPanGestureRecognizer *)gr {
//    CGPoint translatedPoint = [gr translationInView:self];
//    [gr setTranslation:CGPointZero inView:self];
//    self.imageView.center = CGPointMake(self.imageView.center.x + translatedPoint.x, self.imageView.center.y + translatedPoint.y);
//}
//
//- (void)didPinchCell:(UIPinchGestureRecognizer *)gr {
//}

#pragma mark -

- (void)prepareForReuse {
    [self.imageView prepareForReuse];
    self.textLabel.text = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.textLabel.hidden == NO) {
        self.textLabel.frame = CGRectInset(self.bounds, 16.0, 16.0);
        [self fitText];
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
    self.backgroundColor = [UIColor colorWithWhite:0.99 alpha:1.0];
    self.imageScrollView.hidden = YES;
    self.textLabel.hidden = YES;
    self.ytView.hidden = YES;
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
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self.cells removeObject:self];
    }];
}

- (void)editCell {
    // TODO
    PSGridViewCell *cell = self;
    
    [UIActionSheet actionSheetWithTitle:@"Add/Edit Content" message:nil destructiveButtonTitle:nil buttons:@[@"Text", @"Image URL", @"Video", @"Photo", @"Facebook", @"Instagram", @"Remove"] showInView:self onDismiss:^(int buttonIndex, NSString *textInput) {
        
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
                [self showPickerWithSource:@"library"];
                break;
            }
            case 4: {
                [self showPickerWithSource:@"facebook"];
                break;
            }
            case 5: {
                [self showPickerWithSource:@"instagram"];
                break;
            }
            case 6: {
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
    UITouch *touch = [touches anyObject];
    self.originalTouchPoint = [touch locationInView:self.parentView];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.parentView];
    
    if ((fabsf(self.originalTouchPoint.x - touchPoint.x) > 32.0) || (fabsf(self.originalTouchPoint.y - touchPoint.y) > 32.0)) {
        self.touchDidMove = YES;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];

    UITouch *touch = [touches anyObject];
//    CGPoint touchPoint = [touch locationInView:self.parentView];

    // If touch moved too far, cancel it
    if (!self.touchDidMove) {
        if (touch.tapCount == 1) {
            [self editCell];
        } else {
            NSLog(@"long press");
        }
    }
    
    self.touchDidMove = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    self.touchDidMove = NO;
}

#pragma mark -

- (void)showPickerWithSource:(NSString *)source {
    NSDictionary *pickerDict = @{@"source" : source};
    
    id vc = nil;
    if ([source isEqualToString:@"facebook"]) {
        vc = [[FacebookAlbumViewController alloc] initWithNibName:nil bundle:nil];
        [vc setParentDelegate:self];
    } else {
        vc = [[ImagePickerViewController alloc] initWithDictionary:pickerDict];
        [vc setDelegate:self];
    }
    PSNavigationController *nc = [[PSNavigationController alloc] initWithRootViewController:vc];
    
    if (isDeviceIPad()) {
        self.pc = [[UIPopoverController alloc] initWithContentViewController:nc];
        self.pc.popoverContentSize = CGSizeMake(600, 1100);
        [self.pc presentPopoverFromRect:CGRectZero inView:self.parentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        [[[(AppDelegate *)APP_DELEGATE navigationController] topViewController] presentViewController:nc animated:YES completion:NULL];
    }
}


- (void)imagePicker:(ImagePickerViewController *)imagePicker didPickImage:(UIImage *)image {
    
}

- (void)imagePicker:(ImagePickerViewController *)imagePicker didPickImageWithURLPath:(NSString *)URLPath {
    if (isDeviceIPad()) {
        [self.pc dismissPopoverAnimated:YES];
    } else {
        [[[(AppDelegate *)APP_DELEGATE navigationController] topViewController] dismissViewControllerAnimated:YES completion:NULL];
    }
    NSDictionary *content = @{@"type" : @"image", @"href": URLPath};
    self.content = content;
    [self loadContent];
}

@end
