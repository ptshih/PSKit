//
//  PSNewspaperView.h
//  PSKit
//
//  Created by Peter Shih on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSNewspaperCell.h"

@protocol PSNewspaperViewDelegate, PSNewspaperViewDataSource;

@interface PSNewspaperView : UIView

@property (nonatomic, unsafe_unretained) id <PSNewspaperViewDelegate> newspaperViewDelegate;
@property (nonatomic, unsafe_unretained) id <PSNewspaperViewDataSource> newspaperViewDataSource;

@property (nonatomic, assign) NSInteger cellsPerPage;

#pragma mark - Public Methods

/**
 Reloads the collection view
 This is similar to UITableView reloadData)
 */
- (void)reloadData;

@end

#pragma mark - Delegate

@protocol PSNewspaperViewDelegate <NSObject>

@optional
- (void)newspaperView:(PSNewspaperView *)newspaperView didSelectCell:(PSNewspaperCell *)cell atIndex:(NSInteger)index;
- (void)newspaperView:(PSNewspaperView *)newspaperView didShowCell:(PSNewspaperCell *)cell atIndex:(NSInteger)index;

@end

#pragma mark - DataSource

@protocol PSNewspaperViewDataSource <NSObject>

@required
- (NSInteger)numberOfViewsInNewspaperView:(PSNewspaperView *)newspaperView;
- (PSNewspaperCell *)newspaperView:(PSNewspaperView *)newspaperView cellAtIndex:(NSInteger)index;

@end