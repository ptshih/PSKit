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

- (void)editCell:(PSGridViewCell *)cell;

@end


#pragma mark - Delegate

@protocol PSGridViewDelegate <NSObject>

@optional
- (void)gridView:(PSGridView *)gridView didSelectCell:(PSGridViewCell *)cell atIndices:(NSArray *)indices;

@end

#pragma mark - DataSource

@protocol PSGridViewDataSource <NSObject>

@end
