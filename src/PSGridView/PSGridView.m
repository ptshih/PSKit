//
//  PSGridView.m
//  PSKit
//
//  Created by Peter Shih on 12/14/12.
//
//

#import "PSGridView.h"

#pragma mark - UIView Category

@interface UIView (PSCollectionView)

@property(nonatomic, assign) CGFloat left;
@property(nonatomic, assign) CGFloat top;
@property(nonatomic, assign, readonly) CGFloat right;
@property(nonatomic, assign, readonly) CGFloat bottom;
@property(nonatomic, assign) CGFloat width;
@property(nonatomic, assign) CGFloat height;

@end

@implementation UIView (PSCollectionView)

- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

@end


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


#pragma mark - Colors

#define TILE_BG_COLOR [UIColor colorWithRGBHex:0xefefef]
#define TILE_BORDER_COLOR [UIColor colorWithRGBHex:0x9a9a9a]
#define SELECTION_OK_BG_COLOR RGBACOLOR(0, 0, 0, 0.3)
#define SELECTION_ERROR_BG_COLOR RGBACOLOR(255.0, 0, 0, 0.6)
#define SELECTION_BORDER_COLOR [UIColor colorWithRGBHex:0x7a7a7a]


// This is the class for the tile background
@interface PSGridViewTile : UIView

@end

@implementation PSGridViewTile

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = TILE_BG_COLOR;
    }
    return self;
}

@end


@interface PSGridView () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, assign) NSInteger numCols;
@property (nonatomic, assign) NSInteger numRows;

@property (nonatomic, assign) UIInterfaceOrientation orientation;
@property (nonatomic, assign, readwrite) CGFloat lastWidth;
@property (nonatomic, assign, readwrite) CGFloat lastOffset;
@property (nonatomic, assign, readwrite) CGFloat offsetThreshold;

@property (nonatomic, assign) BOOL shouldTouchCell;
@property (nonatomic, assign) CGRect touchRect;
@property (nonatomic, assign) CGPoint touchOrigin;
@property (nonatomic, assign) PSGridViewCell *touchedCell;
@property (nonatomic, assign) PSGridViewTile *touchedTile;
@property (nonatomic, strong) NSMutableSet *touchedIndices;
@property (nonatomic, strong) NSMutableSet *activeTouches;

@property (nonatomic, strong) NSMutableDictionary *tiles;
@property (nonatomic, strong) NSMutableSet *cells;
@property (nonatomic, strong) NSMutableSet *borders;

@property (nonatomic, strong) UIView *gridView;
@property (nonatomic, strong) UIView *selectionView;
    
@end

@implementation PSGridView

#pragma mark - Init/Memory

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.alwaysBounceVertical = YES;
        self.alwaysBounceHorizontal = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;

        self.numCols = 12;
        self.numRows = 24;
        
        self.lastOffset = 0.0;
        self.offsetThreshold = floorf(self.height / 4.0);
        
        self.shouldTouchCell = NO; // determines if cell/tile should be added/edited
        self.touchRect = CGRectZero;
        self.touchedCell = nil;
        self.touchedTile = nil;
        self.touchedIndices = [NSMutableSet set];
        self.activeTouches = [NSMutableSet set];
        
        self.tiles = [NSMutableDictionary dictionary]; // background tiles
        self.cells = [NSMutableSet set]; // active cells
        self.borders = [NSMutableSet set]; // tile borders
        
        // Main grid view
        self.gridView = [[UIView alloc] initWithFrame:CGRectZero];
        self.gridView.backgroundColor = TILE_BORDER_COLOR;
        [self addSubview:self.gridView];
        
        // Selection view (touch overlay)
        self.selectionView = [[UIView alloc] initWithFrame:CGRectZero];
        self.selectionView.userInteractionEnabled = NO;
        self.selectionView.backgroundColor = SELECTION_OK_BG_COLOR;
        self.selectionView.layer.borderWidth = 1.0;
        self.selectionView.layer.borderColor = [SELECTION_BORDER_COLOR CGColor];
        self.selectionView.alpha = 0.0;
        [self.gridView addSubview:self.selectionView];
        
        
        // Create base tiles
        for (int row = 0; row < self.numRows; row++) {
            for (int col = 0; col < self.numCols; col++) {
                PSGridViewTile *tileView = [[PSGridViewTile alloc] initWithFrame:CGRectZero];
                tileView.multipleTouchEnabled = YES;
//                tileView.backgroundColor = RGBCOLOR(arc4random() % 255, arc4random() % 255, arc4random() % 255);
                
                [self.gridView addSubview:tileView];
                [self.tiles setObject:tileView forKey:[self indexForRow:row col:col]];
            }
        }
    }
    
    // Draw Borders
//    [self.borders makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
//    [self.borders removeAllObjects];
//    for (int row = 0; row <= self.numRows; row++) {
//        CALayer *hBorder = [CALayer layer];
//        hBorder.frame = CGRectMake(0, row * [self cellHeight] -0.5, self.gridView.width, 1.0);
//        hBorder.backgroundColor = TILE_BORDER_COLOR.CGColor;
//        hBorder.rasterizationScale = [UIScreen mainScreen].scale;
//        hBorder.shouldRasterize = YES;
//        [self.gridView.layer addSublayer:hBorder];
//        [self.borders addObject:hBorder];
//    }
//    
//    for (int col = 0; col <= self.numCols; col++) {
//        CALayer *vBorder = [CALayer layer];
//        vBorder.frame = CGRectMake(col * [self cellWidth] -0.5, 0, 1.0, self.gridView.height);
//        vBorder.backgroundColor = TILE_BORDER_COLOR.CGColor;
//        vBorder.rasterizationScale = [UIScreen mainScreen].scale;
//        vBorder.shouldRasterize = YES;
//        [self.gridView.layer addSublayer:vBorder];
//        [self.borders addObject:vBorder];
//    }
    
    // Zoom scale
    self.minimumZoomScale = isDeviceIPad() ? 0.6 : 0.5;
    self.maximumZoomScale = 1.0;
    self.zoomScale = 1.0;
    
    return self;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.gridView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self adjustZoomView:scrollView];
}

- (void)adjustZoomView:(UIScrollView *)scrollView {
    UIView *subView = [self viewForZoomingInScrollView:scrollView];
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - Helpers

- (CGFloat)cellWidth {
    return 96.0;
//    return floorf(self.width / self.numCols);
}

- (CGFloat)cellHeight {
    return 96.0;
//    return [self cellWidth] * (3.0 / 4.0);
}

// Returns {row,col} index for row/col
- (NSString *)indexForRow:(NSInteger)row col:(NSInteger)col {
    return [NSString stringWithFormat:@"%d,%d", row, col];
}

// Returns an array of {row,col} indices for a given cell key
- (NSArray *)indicesForKey:(NSString *)key {
    return [key componentsSeparatedByString:@"|"];
}

// Returns a cell key for an array of {row,col} indices
- (NSString *)keyForIndices:(NSArray *)indices {
    return [indices componentsJoinedByString:@"|"];
}

// NOTE: CAN RETURN NIL
- (NSString *)indexForPoint:(CGPoint)point {
    __block NSString *touchIndex = nil;
    [self.tiles enumerateKeysAndObjectsUsingBlock:^(NSString *index, PSGridViewTile *tile, BOOL *stop) {
        if (CGRectContainsPoint(tile.frame, point)) {
            touchIndex = index;
            *stop = YES;
        }
    }];
    
    return touchIndex;
}

// Returns row,col pair of indices for a given rect
- (NSSet *)indicesForRect:(CGRect)rect {
    NSMutableSet *indices = [NSMutableSet set];
    
    [self.tiles enumerateKeysAndObjectsUsingBlock:^(NSString *index, PSGridViewTile *tile, BOOL *stop) {
        if (CGRectIntersectsRect(rect, tile.frame)) {
            [indices addObject:index];
        }
    }];
    
    return [NSSet setWithSet:indices];
}

// Returns combined rect for an array of row,col indices
- (CGRect)rectForIndices:(NSSet *)indices {
    CGRect rect = CGRectNull;
    for (NSString *index in indices) {
        PSGridViewTile *tile = [self.tiles objectForKey:index];
        
        if (CGRectIsNull(rect)) {
            rect = tile.frame;
        } else {
            rect = CGRectUnion(rect, tile.frame);
        }
    }
    
//    NSLog(@"Rect for Indices %@", NSStringFromCGRect(rect));
    return rect;
}

// Returns sequential position for a cell col/row pair
// UNUSED
- (NSInteger)positionForIndex:(NSString *)index {
    NSInteger row = [[[index componentsSeparatedByString:@","] objectAtIndex:0] integerValue];
    NSInteger col = [[[index componentsSeparatedByString:@","] objectAtIndex:1] integerValue];
    
    return (row * self.numCols) + col;
}

// Returns col/row pair for position
// UNUSED
- (NSString *)indexForPosition:(NSInteger)index {
    NSInteger col = index % self.numCols;
    NSInteger row = index / self.numCols;
    
    return [NSString stringWithFormat:@"%d,%d", row, col];
}

// UNUSED
- (NSInteger)rowForIndex:(NSString *)index {
    NSInteger row = [[[index componentsSeparatedByString:@","] objectAtIndex:0] integerValue];
    
    return row;
}

// UNUSED
- (NSInteger)colForIndex:(NSString *)index {
    NSInteger col = [[[index componentsSeparatedByString:@","] objectAtIndex:1] integerValue];
    
    return col;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (self.orientation != orientation) {
        self.orientation = orientation;
        // Recalculates layout
        [self relayoutCells];
        [self adjustZoomView:self];
    } else if(self.lastWidth != self.width) {
        // Recalculates layout
        [self relayoutCells];
    } else {
        // Recycles cells
        CGFloat diff = fabsf(self.lastOffset - self.contentOffset.y);
        
        if (diff > self.offsetThreshold) {
            self.lastOffset = self.contentOffset.y;
        }
    }
    
    self.lastWidth = self.width;
}

- (void)relayoutCells {
    // Layout base tiles
    for (int row = 0; row < self.numRows; row++) {
        for (int col = 0; col < self.numCols; col++) {
            PSGridViewTile *tileView = [self.tiles objectForKey:[self indexForRow:row col:col]];
            CGRect tileRect = CGRectMake(col * [self cellWidth] + (1.0 * col) + 1.0, row * [self cellHeight] + (1.0 * row) + 1.0, [self cellWidth], [self cellHeight]);;
            tileView.frame = tileRect;
        }
    }
    
    // Add existing cells back
    for (PSGridViewCell *cell in self.cells) {
        cell.frame = [self rectForIndices:cell.indices];
        [self.gridView addSubview:cell];
    }
    
    // Calculate content size and frame
    CGFloat width = self.numCols * [self cellWidth] + (1.0 * self.numCols) + 1.0;
    CGFloat height = self.numRows * [self cellHeight] + (1.0 * self.numRows) + 1.0;
    self.contentSize = CGSizeMake(width, height);
    self.gridView.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
}

#pragma mark - Cells

- (void)addCellWithRect:(CGRect)rect {
    if (self.gridViewDataSource) {
        PSGridViewCell *cell = [[PSGridViewCell alloc] initWithFrame:rect];
        [self.gridViewDataSource gridView:self configureCell:cell completionBlock:^(BOOL cellConfigured) {
            if (cellConfigured) {
                // Config success
                [self.gridView insertSubview:cell belowSubview:self.selectionView];
                
                // Add new key
                cell.indices = [self indicesForRect:rect];
                [self.cells addObject:cell];
                
                // Setup gesture recognizer
                if ([cell.gestureRecognizers count] == 0) {
//                    PSGridViewTapGestureRecognizer *gr = [[PSGridViewTapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectCell:)];
//                    gr.delegate = self;
//                    [cell addGestureRecognizer:gr];
                    
                    PSGridViewLongPressGestureRecognizer *lpgr = [[PSGridViewLongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressCell:)];
                    lpgr.delegate = self;
                    [cell addGestureRecognizer:lpgr];
                    
                    cell.userInteractionEnabled = YES;
                }
                [self endTouches];
            } else {
                // Config aborted
                [self endTouches];
            }
        }];
    } else {
        [self endTouches];
    }
}

- (void)editCell:(PSGridViewCell *)cell {
    if (self.gridViewDelegate && [self.gridViewDelegate respondsToSelector:@selector(gridView:didSelectCell:atIndices:completionBlock:)]) {
        [self.gridViewDelegate gridView:self didSelectCell:(PSGridViewCell *)cell atIndices:cell.indices completionBlock:^(BOOL cellConfigured) {
            [self endTouches];
        }];
    }
}

// Remove cell
- (void)removeCell:(PSGridViewCell *)cell {
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        cell.alpha = 0.0;
    } completion:^(BOOL finished) {
        [cell removeFromSuperview];
        [self.cells removeObject:cell];
    }];
}

#pragma mark - Gesture Recognizer

- (void)didSelectCell:(UITapGestureRecognizer *)gestureRecognizer {
    // unused
}

- (void)didLongPressCell:(UILongPressGestureRecognizer *)gestureRecognizer {
//    NSLog(@"%d", gestureRecognizer.state);
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        if (self.gridViewDelegate && [self.gridViewDelegate respondsToSelector:@selector(gridView:didLongPressCell:atIndices:completionBlock:)]) {
            PSGridViewCell *cell = (PSGridViewCell *)gestureRecognizer.view;
            [self.gridViewDelegate gridView:self didLongPressCell:cell atIndices:cell.indices completionBlock:^(BOOL cellRemoved) {
                if (cellRemoved) {
                    [self removeCell:cell];
                }
            }];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (![gestureRecognizer isMemberOfClass:[PSGridViewTapGestureRecognizer class]] && ![gestureRecognizer isMemberOfClass:[PSGridViewLongPressGestureRecognizer class]]) return YES;
    
    if ([touch.view isKindOfClass:[PSGridViewCell class]]) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Selection View
- (void)showSelectionView:(BOOL)animated withRect:(CGRect)rect {
    self.selectionView.frame = rect;
    [self.gridView bringSubviewToFront:self.selectionView];
    self.selectionView.backgroundColor = SELECTION_OK_BG_COLOR;
    if (self.selectionView.alpha != 1.0) {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.selectionView.alpha = 1.0;
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)hideSelectionView:(BOOL)animated {
    CGFloat animateDuration = animated ? 0.2 : 0.0;
    [UIView animateWithDuration:animateDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.selectionView.alpha = 0.0;
    } completion:^(BOOL finished) {
        
    }];
}


#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    [self beginTouches];
    
    // Figure out if we touched an existing cell
    for (UITouch *touch in touches) {
        CGPoint touchPoint = [touch locationInView:self.gridView];
        self.touchOrigin = touchPoint;
        
        if (!self.touchedCell && !self.touchedTile && [touch.view isKindOfClass:[PSGridViewCell class]]) {
            // Cell
            self.touchedCell = (PSGridViewCell *)touch.view;
            self.shouldTouchCell = YES;
            
            [self.touchedIndices unionSet:[(PSGridViewCell *)touch.view indices]];
        } else if (!self.touchedTile && !self.touchedCell && [touch.view isKindOfClass:[PSGridViewTile class]]) {
            // Tile
            self.touchedTile = (PSGridViewTile *)touch.view;
            self.shouldTouchCell = YES;
        } else {
            // Neither cell nor tile
            self.shouldTouchCell = NO;
        }
        
        // Add all touches
        NSString *touchIndex = [self indexForPoint:touchPoint];
        if (touchIndex) {
            [self.touchedIndices addObject:touchIndex];
        }
        
        // Show selection view overlay
        [self showSelectionView:YES withRect:[self rectForIndices:self.touchedIndices]];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    [self.activeTouches unionSet:touches];
    
//    for (UITouch *touch in touches) {
//        CGPoint touchPoint = [touch locationInView:self.gridView];
//        
//        // Add all touches
//        NSString *touchIndex = [self indexForPoint:touchPoint];
//        if (touchIndex) {
//            [self.movedIndices addObject:touchIndex];
//        }
//    }
    
    // We are now pinching
    if (self.activeTouches.count == 2) {
        NSArray *allActiveTouches = [self.activeTouches allObjects];
        CGPoint p0, p1;
        p0 = [[allActiveTouches objectAtIndex:0] locationInView:self.gridView];
        p1 = [[allActiveTouches objectAtIndex:1] locationInView:self.gridView];
        
        CGRect touchRect = CGRectMake(MIN(p0.x, p1.x), MIN(p0.y, p1.y), fabsf(p0.x - p1.x), fabsf(p0.y - p1.y));
        NSSet *movedIndices = [self indicesForRect:touchRect];
        
        // This is the new proposed cell rect
        CGRect newCellRect = [self rectForIndices:movedIndices];
        
        // Show selection view overlay
        [self showSelectionView:YES withRect:newCellRect];
        
        // Check to see if the current touch rectangle conflicts with any existing cells
        BOOL hasConflict = NO;
        for (PSGridViewCell *cell in self.cells) {
            // Only conflict with other cells, not itself
            if (![cell isEqual:self.touchedCell]) {
                // If current touch area intersects an existing cell, we have a conflict
                if (CGRectIntersectsRect(newCellRect, cell.frame)) {
                    hasConflict = YES;
                }
            }
        }
        
        // No conflict with existing cells
        if (!hasConflict) {
            // We are modifying an existing cell
            // if new rect is wholly resides in existing rect, this is a shrink
            if (CGRectContainsRect(self.touchedCell.frame, newCellRect)) {
                self.touchedCell.frame = newCellRect;
            } else {
                self.touchedCell.frame = CGRectUnion(newCellRect, self.touchedCell.frame);
            }
            
            self.touchedCell.indices = [self indicesForRect:self.touchedCell.frame];
            self.shouldTouchCell = NO;
        } else {
            // Conflicting cell, No-Op
            self.selectionView.backgroundColor = SELECTION_ERROR_BG_COLOR;
            self.shouldTouchCell = NO;
        }
    } else if (self.touchedTile && !self.touchedCell && self.activeTouches.count == 1) {
        // Find the touch rectangle from origin to destination
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInView:self.gridView];
        CGPoint p0, p1;
        p0 = self.touchOrigin;
        p1 = touchPoint;
        
        CGRect touchRect = CGRectMake(MIN(p0.x, p1.x), MIN(p0.y, p1.y), fabsf(p0.x - p1.x), fabsf(p0.y - p1.y));
        NSSet *movedIndices = [self indicesForRect:touchRect];
        
        // This is the new proposed cell rect
        CGRect newCellRect = [self rectForIndices:movedIndices];
        
        // Show selection view overlay
        [self showSelectionView:YES withRect:newCellRect];
        
        // Check to see if the current touch rectangle conflicts with any existing cells
        BOOL hasConflict = NO;
        for (PSGridViewCell *cell in self.cells) {
            // Only conflict with other cells, not itself
            if (![cell isEqual:self.touchedCell]) {
                // If current touch area intersects an existing cell, we have a conflict
                if (CGRectIntersectsRect(newCellRect, cell.frame)) {
                    hasConflict = YES;
                }
            }
        }
        
        // No conflict with existing cells
        if (!hasConflict) {
            [self.touchedIndices unionSet:movedIndices];
            self.shouldTouchCell = YES;
        } else {
            // Conflicting cell, No-Op
            self.selectionView.backgroundColor = SELECTION_ERROR_BG_COLOR;
            self.shouldTouchCell = NO;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    for (UITouch *touch in touches) {
        UIView *touchView = touch.view;
        if (self.shouldTouchCell && self.touchedTile && [touchView isKindOfClass:[PSGridViewTile class]]) {
            // new cell
            
            // This is the new proposed cell rect
            CGRect newCellRect = [self rectForIndices:self.touchedIndices];
            
            // Add a new cell
            // Show selection view overlay
            [self showSelectionView:YES withRect:newCellRect];
            [self addCellWithRect:newCellRect];
        } else if (self.shouldTouchCell && self.touchedCell && [touchView isKindOfClass:[PSGridViewCell class]]) {
            // existing cell
            
            // Edit a cell
            // Show selection view overlay
            [self showSelectionView:YES withRect:self.touchedCell.frame];
            [self editCell:self.touchedCell];
        } else {
            // neither cell nor tile
            [self endTouches];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self endTouches];
}

- (void)beginTouches {
    // Disable UIScrollView scrolling
    self.scrollEnabled = NO;
    self.pinchGestureRecognizer.enabled = NO;
    self.panGestureRecognizer.enabled = NO;
}

- (void)endTouches {
    // Hide selection view
    [self hideSelectionView:YES];
    
    self.shouldTouchCell = NO;
    
    // Reset touched cell and tile
    self.touchedCell = nil;
    self.touchedTile = nil;
    
    // Remove all touched indices
    [self.touchedIndices removeAllObjects];
    [self.activeTouches removeAllObjects];
    
    // Re-enable scrollview scrolling and gesture detection
    self.scrollEnabled = YES;
    self.pinchGestureRecognizer.enabled = YES;
    self.panGestureRecognizer.enabled = YES;
}

@end
