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
@property (nonatomic, strong, readonly) NSDictionary *content;

@property (nonatomic, unsafe_unretained) id <PSGridViewCellDelegate> delegate;

- (void)loadContent:(NSDictionary *)content;

@end

@protocol PSGridViewCellDelegate <NSObject>

@optional
- (void)gridViewCell:(PSGridViewCell *)gridViewCell didTapWithWithState:(UIGestureRecognizerState)state;
- (void)gridViewCell:(PSGridViewCell *)gridViewCell didLongPressWithState:(UIGestureRecognizerState)state;

@end
