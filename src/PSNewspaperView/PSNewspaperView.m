//
//  PSNewspaperView.m
//  Satsuma
//
//  Created by Peter Shih on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSNewspaperView.h"

#pragma mark - Gesture Recognizer

// This is just so we know that we sent this tap gesture recognizer in the delegate
@interface PSNewspaperViewTapGestureRecognizer : UITapGestureRecognizer
@end

@implementation PSNewspaperViewTapGestureRecognizer
@end

@interface PSNewspaperView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) NSMutableArray *cells;
@property (nonatomic, strong) NSMutableArray *dividers;

@end

@implementation PSNewspaperView

@synthesize
newspaperViewDelegate = _newspaperViewDelegate,
newspaperViewDataSource = _newspaperViewDataSource;

@synthesize
scrollView = _scrollView,
pageControl = _pageControl;

@synthesize
cells = cells,
dividers = _dividers;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(0, 0, 19.0, 0))];
        self.scrollView.delegate = self;
        self.scrollView.backgroundColor = [UIColor whiteColor];
        self.scrollView.scrollEnabled = YES;
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.scrollsToTop = NO;
        self.scrollView.userInteractionEnabled = YES;
        [self addSubview:self.scrollView];
        
        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0, self.height - 19.0, self.width, 19.0)];
        self.pageControl.backgroundColor = [UIColor blackColor];
        self.pageControl.userInteractionEnabled = NO;
        [self addSubview:self.pageControl];
        
        self.cells = [NSMutableArray array];
        self.dividers = [NSMutableArray array];
    }
    return self;
}

#pragma mark - DataSource

- (void)reloadData {
    [self.cells removeAllObjects];
    
    NSInteger numViews = [self.newspaperViewDataSource numberOfViewsInNewspaperView:self];
    self.pageControl.numberOfPages = ceil(numViews / 3.0);
    self.pageControl.currentPage = 0;
    
    for (int i = 0; i < numViews; i++) {
        PSNewspaperCell *cell = [self.newspaperViewDataSource newspaperView:self cellAtIndex:i];
        
        PSNewspaperViewTapGestureRecognizer *gr = [[PSNewspaperViewTapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectCell:)];
        [cell addGestureRecognizer:gr];
        
        [self.scrollView addSubview:cell];
        [self.cells addObject:cell];
    }
    
    // load first page
    [self didShowPage:0];
    
    [self setNeedsLayout];
}

#pragma mark - View

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSInteger numViews = [self.newspaperViewDataSource numberOfViewsInNewspaperView:self];
    NSInteger numPages = ceil(numViews / 3.0);
    
    NSInteger prevPage = self.pageControl.currentPage;
    
    self.scrollView.frame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(0, 0, 19.0, 0));
    self.pageControl.frame = CGRectMake(0.0, self.height - 19.0, self.width, 19.0);
    
    //    CGFloat contentWidth = self.scrollView.contentSize.width;
    //    CGFloat contentHeight = self.scrollView.contentSize.height;
    CGFloat pageWidth = self.scrollView.width;
    CGFloat pageHeight = self.scrollView.height;
    
    
    self.scrollView.contentSize = CGSizeMake(numPages * pageWidth, pageHeight);
    self.scrollView.contentOffset = CGPointMake(prevPage * pageWidth, 0.0);
    
    [self.dividers makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.dividers removeAllObjects];
    
    int i = 0;
    int pos = 0;
    int page = 0;
    
    CGFloat top = 0.0;
    CGFloat left = 0.0;
    CGFloat remWidth = 0.0;
    CGFloat remHeight = 0.0;
    
    for (PSNewspaperCell *cell in self.cells) {
        pos = i % 3;
        page = i / 3;
        
        // Reset remaining frame
        if (pos == 0) {
            top = 0.0;
            left = 0.0;
            
        }
        
        // Always layout the featured image first
        // Then calculate remaining frame to layout the rest
        
        if (self.scrollView.height > self.scrollView.width) {
            // Portrait
            // Large
            if (pos == 0) {
                CGFloat cellHeight = floorf(pageHeight * 0.5);
                
                cell.frame = CGRectMake(left + pageWidth * page, top, pageWidth, cellHeight);
                
                top += cell.height;
                
                remWidth = pageWidth;
                remHeight = pageHeight - top;
                
                UIView *d = [[UIView alloc] initWithFrame:CGRectMake(cell.left + 16.0, cell.bottom, cell.width - 32.0, 1.0)];
                d.backgroundColor = RGBACOLOR(200, 200, 200, 1.0);
                [self.scrollView addSubview:d];
                [self.dividers addObject:d];
            }
            
            // Small 1
            if (pos == 1) {
                CGFloat cellWidth = floorf(remWidth * 0.5);
                
                cell.frame = CGRectMake(pageWidth * page, top, cellWidth, remHeight);
                
                UIView *d = [[UIView alloc] initWithFrame:CGRectMake(cell.right, cell.top, 1.0, cell.height - 16.0)];
                d.backgroundColor = RGBACOLOR(200, 200, 200, 1.0);
                [self.scrollView addSubview:d];
                [self.dividers addObject:d];
                
                left += cell.width;
                
                remWidth = pageWidth - left;
            }
            
            // Small 2
            if (pos == 2) {
                cell.frame = CGRectMake(left + pageWidth * page, top, remWidth, remHeight);
            }
            
        } else {
            // Landscape
            // Large
            if (pos == 0) {
                CGFloat cellWidth = floorf(pageWidth * 0.45);
                
                cell.frame = CGRectMake(pageWidth * page, top, cellWidth, pageHeight);
                
                left += cell.width;
                
                remWidth = pageWidth - left;
                remHeight = pageHeight;
                
                UIView *d = [[UIView alloc] initWithFrame:CGRectMake(cell.right, cell.top, 1.0, cell.height - 16.0)];
                d.backgroundColor = RGBACOLOR(200, 200, 200, 1.0);
                [self.scrollView addSubview:d];
                [self.dividers addObject:d];
            }
            
            // Small 1
            if (pos == 1) {
                CGFloat cellHeight = floorf(remHeight * 0.5);
                
                cell.frame = CGRectMake(left + pageWidth * page, top, remWidth, cellHeight);
                
                UIView *d = [[UIView alloc] initWithFrame:CGRectMake(cell.left, cell.bottom, cell.width - 16.0, 1.0)];
                d.backgroundColor = RGBACOLOR(200, 200, 200, 1.0);
                [self.scrollView addSubview:d];
                [self.dividers addObject:d];
                
                top += cell.height;
                
                remHeight = pageHeight - top;
            }
            
            // Small 2
            if (pos == 2) {
                cell.frame = CGRectMake(left + pageWidth * page, top, remWidth, remHeight);
            }
        }
        
        i++;
    }
}

- (NSInteger)currentPage {
    CGFloat pageWidth = self.scrollView.frame.size.width;
    float fractionalPage = self.scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    
    return page;
}

- (void)didShowPage:(NSInteger)page {
    NSInteger fromIndex = MAX(0, page * 3);
    NSInteger toIndex = MIN(self.cells.count, fromIndex + 3);
    
    for (int i = fromIndex; i < toIndex; i++) {
        if (self.newspaperViewDelegate && [self.newspaperViewDelegate respondsToSelector:@selector(newspaperView:didShowCell:atIndex:)]) {
            [self.newspaperViewDelegate newspaperView:self didShowCell:[self.cells objectAtIndex:i] atIndex:i];
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    static NSInteger previousPage = 0;

    NSInteger page = [self currentPage];
    if (previousPage != page) {
        // Page has changed
        // Do your thing!
        previousPage = page;
        self.pageControl.currentPage = page;
        
        [self didShowPage:page];
    }
    
}

#pragma mark - Gesture Recognizer

- (void)didSelectCell:(UITapGestureRecognizer *)gestureRecognizer {
    PSNewspaperCell *cell = (PSNewspaperCell *)gestureRecognizer.view;
    
    NSInteger cellIndex = [self.cells indexOfObject:cell];
    
    if (self.newspaperViewDelegate && [self.newspaperViewDelegate respondsToSelector:@selector(newspaperView:didSelectCell:atIndex:)]) {
        [self.newspaperViewDelegate newspaperView:self didSelectCell:cell atIndex:cellIndex];
    }
    
}

@end
