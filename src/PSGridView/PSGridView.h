//
//  PSGridView.h
//  PSKit
//
//  Created by Peter Shih on 12/14/12.
//
//

#import <UIKit/UIKit.h>

#import "PSGridViewCell.h"

@protocol PSGridViewDelegate, PSGridViewDataSource;

@interface PSGridView : UIScrollView

@property (nonatomic, unsafe_unretained) id <PSGridViewDelegate> gridViewDelegate;
@property (nonatomic, unsafe_unretained) id <PSGridViewDataSource> gridViewDataSource;

@end


#pragma mark - Delegate

@protocol PSGridViewDelegate <NSObject>

@optional
- (void)gridView:(PSGridView *)gridView didSelectCell:(PSGridViewCell *)cell atIndices:(NSSet *)indices completionBlock:(void (^)(BOOL cellConfigured))completionBlock;
- (void)gridView:(PSGridView *)gridView didLongPressCell:(PSGridViewCell *)cell atIndices:(NSSet *)indices completionBlock:(void (^)(BOOL cellRemoved))completionBlock;

@end

#pragma mark - DataSource

@protocol PSGridViewDataSource <NSObject>

@required
- (void)gridView:(PSGridView *)gridView configureCell:(PSGridViewCell *)cell completionBlock:(void (^)(BOOL cellConfigured))completionBlock;

@end
