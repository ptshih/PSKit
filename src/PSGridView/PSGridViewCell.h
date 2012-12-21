//
//  PSGridViewCell.h
//  PSKit
//
//  Created by Peter Shih on 12/14/12.
//
//

#import <UIKit/UIKit.h>

@protocol PSGridViewCellDelegate;

@interface PSGridViewCell : UIView

@property (nonatomic, strong) NSSet *indices;
@property (nonatomic, strong) NSDictionary *content;

@property (nonatomic, assign) UIView *parentView;
@property (nonatomic, assign) NSMutableSet *cells;

@property (nonatomic, unsafe_unretained) id <PSGridViewCellDelegate> delegate;

- (void)loadContent;
- (void)showHighlight;
- (void)hideHighlight;
- (void)enableVideoTouch;
- (void)disableVideoTouch;

@end

@protocol PSGridViewCellDelegate <NSObject>

@optional
- (void)gridViewCell:(PSGridViewCell *)gridViewCell didTapWithWithState:(UIGestureRecognizerState)state;
- (void)gridViewCell:(PSGridViewCell *)gridViewCell didLongPressWithState:(UIGestureRecognizerState)state;

@end
