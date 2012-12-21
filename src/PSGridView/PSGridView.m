//
//  PSGridView.m
//  PSKit
//
//  Created by Peter Shih on 12/14/12.
//
//

#import "PSGridView.h"
#import "UIView+PSKit.h"


@interface GridView : UIView

@end

@implementation GridView

@end

@interface SelectionView : UIView

@end

@implementation SelectionView

@end

@interface TargetView : UIView

@end

@implementation TargetView

@end


@interface PSGridView () <UIScrollViewDelegate, PSGridViewCellDelegate>

// Models
@property (nonatomic, strong) NSMutableSet *tiles;
@property (nonatomic, strong) NSMutableSet *cells;
@property (nonatomic, strong) NSMutableSet *borders;
@property (nonatomic, strong) NSMutableSet *targets;

// Views
@property (nonatomic, strong) GridView *gridView;
@property (nonatomic, strong) SelectionView *selectionView;
@property (nonatomic, strong) TargetView *targetView;

// Config
@property (nonatomic, assign) NSInteger numCols;
@property (nonatomic, assign) NSInteger numRows;
@property (nonatomic, assign) CGFloat margin;
@property (nonatomic, strong) UIColor *tileColor;
@property (nonatomic, strong) UIColor *tileBorderColor;
@property (nonatomic, strong) UIColor *selectionTileColor;
@property (nonatomic, strong) UIColor *selectionCellColor;
@property (nonatomic, strong) UIColor *selectionTargetColor;
@property (nonatomic, strong) UIColor *selectionErrorColor;
@property (nonatomic, strong) UIColor *selectionBorderColor;

// Touch
@property (nonatomic, assign) BOOL inTargetMode;
@property (nonatomic, assign) CGPoint originalTouchPoint;
@property (nonatomic, strong) NSMutableSet *touchedIndices;
@property (nonatomic, strong) id selectedView;
@property (nonatomic, strong) Class activeTouchClass;

// Orientation
@property (nonatomic, assign) UIInterfaceOrientation orientation;
@property (nonatomic, assign) CGFloat lastWidth;

    
@end

@implementation PSGridView

#pragma mark - Init/Memory

- (id)initWithFrame:(CGRect)frame dictionary:(NSDictionary *)dictionary {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.alwaysBounceVertical = YES;
        self.alwaysBounceHorizontal = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.multipleTouchEnabled = NO;

        // Config
        self.numCols = 12;
        self.numRows = 16;
        self.margin = 2.0;
        self.tileColor = [UIColor colorWithWhite:0.99 alpha:1.0];
        self.tileBorderColor = [UIColor colorWithWhite:0.85 alpha:1.0];
        self.selectionTileColor = RGBACOLOR(200, 200, 200, 0.5);
        self.selectionCellColor = RGBACOLOR(0, 0, 255.0, 0.5);
        self.selectionTargetColor = RGBACOLOR(0.0, 255.0, 0, 0.5);
        self.selectionErrorColor = RGBACOLOR(255.0, 0, 0, 0.5);
        self.selectionBorderColor = [UIColor colorWithRGBHex:0x9a9a9a];
        
        // Models
        self.tiles = [NSMutableSet set]; // background tiles
        self.cells = [NSMutableSet set]; // active cells
        self.borders = [NSMutableSet set]; // tile borders
        self.targets = [NSMutableSet set]; // tap targets
        
        // Touch Config
        self.inTargetMode = NO;
        self.originalTouchPoint = CGPointMake(-1, -1);
        self.touchedIndices = [NSMutableSet set];
        self.activeTouchClass = nil;
        self.selectedView = nil;
        
        // Main grid view
        self.gridView = [[GridView alloc] initWithFrame:CGRectZero];
        self.gridView.backgroundColor = self.tileBorderColor;
        [self addSubview:self.gridView];
        
        // Create base tiles
        for (int row = 0; row < self.numRows; row++) {
            for (int col = 0; col < self.numCols; col++) {
                PSGridViewTile *tileView = [[PSGridViewTile alloc] initWithFrame:CGRectZero];
                tileView.index = [self indexForRow:row col:col];
                tileView.backgroundColor = self.tileColor;
                [self.tiles addObject:tileView];
                [self.gridView addSubview:tileView];
            }
        }
        
        self.targetView = [[TargetView alloc] initWithFrame:CGRectZero];
        self.targetView.backgroundColor = [UIColor blackColor];
        self.targetView.alpha = 0.0;
        [self.gridView addSubview:self.targetView];
        
        // Selection view (touch overlay)
        self.selectionView = [[SelectionView alloc] initWithFrame:CGRectZero];
        self.selectionView.userInteractionEnabled = NO;
        self.selectionView.backgroundColor = self.selectionErrorColor;
        self.selectionView.layer.borderWidth = 2.0;
        self.selectionView.layer.borderColor = [self.selectionBorderColor CGColor];
        self.selectionView.alpha = 0.0;
        [self.gridView addSubview:self.selectionView];
        
        // Zoom scale
        self.minimumZoomScale = isDeviceIPad() ? 0.8 : 0.5;
        self.maximumZoomScale = 2.0;
        self.zoomScale = 1.0;
        
        if (dictionary) {
            [self importData:dictionary];
        }
        
        // Draw Borders
//        [self.borders makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
//        [self.borders removeAllObjects];
//        for (int row = 0; row <= self.numRows; row++) {
//            CALayer *hBorder = [CALayer layer];
//            hBorder.frame = CGRectMake(0, row * [self cellHeight] + (1.0 * row), self.gridView.width, 1.0);
//            hBorder.backgroundColor = TILE_BORDER_COLOR.CGColor;
//            hBorder.rasterizationScale = [UIScreen mainScreen].scale;
//            hBorder.shouldRasterize = YES;
//            [self.gridView.layer addSublayer:hBorder];
//            [self.borders addObject:hBorder];
//        }
//        
//        for (int col = 0; col <= self.numCols; col++) {
//            CALayer *vBorder = [CALayer layer];
//            vBorder.frame = CGRectMake(col * [self cellWidth] + (1.0 * col), 0, 1.0, self.gridView.height);
//            vBorder.backgroundColor = TILE_BORDER_COLOR.CGColor;
//            vBorder.rasterizationScale = [UIScreen mainScreen].scale;
//            vBorder.shouldRasterize = YES;
//            [self.gridView.layer addSublayer:vBorder];
//            [self.borders addObject:vBorder];
//        }
    }
    
    return self;
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
    }
    
    self.lastWidth = self.width;
}

- (void)relayoutCells {
    self.zoomScale = 1.0;
    
    // Calculate content size and frame
    CGFloat width = self.numCols * [self cellWidth] + (self.margin * self.numCols) + self.margin;
    CGFloat height = self.numRows * [self cellHeight] + (self.margin * self.numRows) + self.margin;
    self.contentSize = CGSizeMake(width, height);
    self.gridView.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
    self.targetView.frame = self.gridView.bounds;
    
    // Layout base tiles
    for (PSGridViewTile *tile in self.tiles) {
        CGFloat row = [self rowForIndex:tile.index];
        CGFloat col = [self colForIndex:tile.index];
        CGRect tileRect = CGRectMake(col * [self cellWidth] + (self.margin * col) + self.margin, row * [self cellHeight] + (self.margin * row) + self.margin, [self cellWidth], [self cellHeight]);
        tile.frame = tileRect;
    }
    
    for (PSGridViewCell *cell in self.cells) {
        CGRect cellRect = [self rectForIndices:cell.indices];
        cell.frame = cellRect;
        [self.gridView bringSubviewToFront:cell];
    }
    
    for (PSGridViewTarget *target in self.targets) {
        CGRect cellRect = [self rectForIndices:target.indices];
        target.frame = cellRect;
        [self.gridView bringSubviewToFront:target];
    }
}

#pragma mark - Cells

- (void)addTargetWithRect:(CGRect)rect {
    PSGridViewTarget *target = [[PSGridViewTarget alloc] initWithFrame:rect];
    target.parentView = self;
    target.targets = self.targets;
    target.indices = [self indicesForRect:rect];
    [self.targets addObject:target];
    [self.targetView addSubview:target];
}

- (void)addCellWithRect:(CGRect)rect {
    PSGridViewCell *cell = [[PSGridViewCell alloc] initWithFrame:rect];
    cell.parentView = self;
    cell.delegate = self;
    cell.layer.borderColor = RGBACOLOR(0, 160, 200, 0.5).CGColor;
    cell.layer.borderWidth = 2.0;
    cell.cells = self.cells;
    cell.indices = [self indicesForRect:rect];
    
    [self.cells addObject:cell];
    [self.gridView insertSubview:cell belowSubview:self.selectionView];
}

#pragma mark - Touches

// We are only detecting touches for self.gridView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    
    // Only allow one type of view to be touched at a time
    if (!self.activeTouchClass) {
        self.activeTouchClass = [touch.view class];
    } else {
        return;
    }
    
    [self beginTouches];
    
    CGPoint touchPoint = [touch locationInView:self.gridView];
    self.originalTouchPoint = touchPoint;
    
    if (self.activeTouchClass == [PSGridViewCell class] || self.activeTouchClass == [PSGridViewTarget class]) {
        // Resizing
        self.selectedView = touch.view;
        if ([self.selectedView respondsToSelector:@selector(showHighlight)]) {
            [self.selectedView performSelector:@selector(showHighlight)];
        }
        
        // Find out which corner of the tile was touched
        UIView *v = self.selectedView;
        CGFloat dx = [self cellWidth];
        CGFloat dy = [self cellHeight];
        CGFloat left = v.left;
        CGFloat right = v.right;
        CGFloat top = v.top;
        CGFloat bottom = v.bottom;
        CGRect topLeft = CGRectMake(left, top, dx, dy);
        CGRect topRight = CGRectMake(right - dx, top, dx, dy);
        CGRect bottomLeft = CGRectMake(left, bottom - dy, dx, dy);
        CGRect bottomRight = CGRectMake(right - dx, bottom - dy, dx, dy);
        
        if (CGRectContainsPoint(bottomRight, touchPoint)) {
            self.originalTouchPoint = CGPointMake(left, top);
        } else if (CGRectContainsPoint(bottomLeft, touchPoint)) {
            self.originalTouchPoint = CGPointMake(right, top);
        } else if (CGRectContainsPoint(topRight, touchPoint)) {
            self.originalTouchPoint = CGPointMake(left, bottom);
        } else if (CGRectContainsPoint(topLeft, touchPoint)) {
            self.originalTouchPoint = CGPointMake(right, bottom);
        } else {
            self.originalTouchPoint = CGPointMake(-1, -1);
        }
        
        if (self.activeTouchClass == [PSGridViewCell class]) {
            self.selectionView.backgroundColor = self.selectionTileColor;
        } else if (self.activeTouchClass == [PSGridViewTarget class]) {
            self.selectionView.backgroundColor = self.selectionTargetColor;
        }
    } else if (self.activeTouchClass == [PSGridViewTile class] || self.activeTouchClass == [TargetView class]) {
        // Normal Tile
        
        // Find out which tile was touched
        for (PSGridViewTile *tile in self.tiles) {
            if (CGRectContainsPoint(tile.frame, touchPoint)) {
                [self.touchedIndices addObject:tile.index];
                break;
            }
        }
        
        if (self.activeTouchClass == [PSGridViewTile class]) {
            self.selectionView.backgroundColor = self.selectionTileColor;
        } else if (self.activeTouchClass == [TargetView class]) {
            self.selectionView.backgroundColor = self.selectionTargetColor;
        }
        
        // Show selection view overlay
        [self showSelectionViewWithRect:[self rectForIndices:self.touchedIndices] animated:YES];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    
    // Only allow one type of view to be touched at a time
    if (touch.view.class != self.activeTouchClass) return;
    
    CGPoint touchPoint = [touch locationInView:self.gridView];
    
    if (self.activeTouchClass == [PSGridViewCell class] || self.activeTouchClass == [PSGridViewTarget class]) {
        // Resizing
        
        if (!CGPointEqualToPoint(self.originalTouchPoint, CGPointMake(-1, -1))) {
            CGPoint p1, p2;
            p1 = self.originalTouchPoint;
            p2 = touchPoint;
            CGRect touchRect = CGRectMake(MIN(p1.x, p2.x), MIN(p1.y, p2.y), fabsf(p1.x - p2.x), fabsf(p1.y - p2.y));
            
            NSSet *movedIndices = [self indicesForRect:touchRect];
            
            if (movedIndices.count > 0) {
                // This is the new proposed cell rect
                CGRect resizedRect = [self rectForIndices:movedIndices];
                
                
                // Check to see if the current touch rectangle conflicts with any existing cells
                BOOL hasConflict = NO;
                
                if (self.inTargetMode) {
                    for (PSGridViewTarget *target in self.targets) {
                        // If current touch area intersects an existing cell, we have a conflict
                        if (![target isEqual:self.selectedView]) {
                            // If current touch area intersects an existing cell, we have a conflict
                            if (CGRectIntersectsRect(resizedRect, target.frame)) {
                                hasConflict = YES;
                            }
                        }
                    }
                } else {
                    for (PSGridViewCell *cell in self.cells) {
                        // If current touch area intersects an existing cell, we have a conflict
                        if (![cell isEqual:self.selectedView]) {
                            // If current touch area intersects an existing cell, we have a conflict
                            if (CGRectIntersectsRect(resizedRect, cell.frame)) {
                                hasConflict = YES;
                            }
                        }
                    }
                }
                
                
                if (!hasConflict) {
                    UIView *v = self.selectedView;
                    v.frame = resizedRect;
                    [self.touchedIndices setSet:movedIndices];
                }
            }
        }
    } else if (self.activeTouchClass == [PSGridViewTile class] || self.activeTouchClass == [TargetView class]) {
        // Normal Tile
        
        CGPoint p1, p2;
        p1 = self.originalTouchPoint;
        p2 = touchPoint;
        CGRect touchRect = CGRectMake(MIN(p1.x, p2.x), MIN(p1.y, p2.y), fabsf(p1.x - p2.x), fabsf(p1.y - p2.y));
        NSSet *movedIndices = [self indicesForRect:touchRect];
        
        // This is the new proposed cell rect
        CGRect newCellRect = [self rectForIndices:movedIndices];
        
        // Check to see if the current touch rectangle conflicts with any existing cells
        BOOL hasConflict = NO;
        
        if (self.inTargetMode) {
            for (PSGridViewTarget *target in self.targets) {
                // If current touch area intersects an existing cell, we have a conflict
                if (CGRectIntersectsRect(newCellRect, target.frame)) {
                    hasConflict = YES;
                }
            }
        } else {
            for (PSGridViewCell *cell in self.cells) {
                // If current touch area intersects an existing cell, we have a conflict
                if (CGRectIntersectsRect(newCellRect, cell.frame)) {
                    hasConflict = YES;
                }
            }
        }
        
        // No conflict with existing cells
        if (!hasConflict) {
            if (self.inTargetMode) {
                self.selectionView.backgroundColor = self.selectionTargetColor;
            } else {
                self.selectionView.backgroundColor = self.selectionTileColor;
            }
        } else {
            // Conflicting cell, No-Op
            self.selectionView.backgroundColor = self.selectionErrorColor;
        }
        
        [self.touchedIndices setSet:movedIndices];
        
        // Show selection view overlay
        [self showSelectionViewWithRect:[self rectForIndices:self.touchedIndices] animated:YES];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
//    CGPoint touchPoint = [touch locationInView:self.gridView];
    
    // Only allow one type of view to be touched at a time
    if (touch.view.class != self.activeTouchClass) return;
    
    if (self.touchedIndices.count > 0) {
        if (self.activeTouchClass == [PSGridViewCell class] || self.activeTouchClass == [PSGridViewTarget class]) {
            // Taps get handled by the individual cells
            // Resize
            [self.selectedView setIndices:[NSSet setWithSet:self.touchedIndices]];
            
        } else if (self.activeTouchClass == [PSGridViewTile class] || self.activeTouchClass == [TargetView class]) {
            CGRect finalRect = [self rectForIndices:self.touchedIndices];
            
            // Check to see if the current touch rectangle conflicts with any existing cells
            BOOL hasConflict = NO;
            if (self.inTargetMode) {
                for (PSGridViewTarget *target in self.targets) {
                    // If current touch area intersects an existing cell, we have a conflict
                    if (CGRectIntersectsRect(finalRect, target.frame)) {
                        hasConflict = YES;
                    }
                }
                
                if (!hasConflict) {
                    [self addTargetWithRect:finalRect];
                }
            } else {
                for (PSGridViewCell *cell in self.cells) {
                    // If current touch area intersects an existing cell, we have a conflict
                    if (CGRectIntersectsRect(finalRect, cell.frame)) {
                        hasConflict = YES;
                    }
                }
                
                if (!hasConflict) {
                    [self addCellWithRect:finalRect];
                }
            }
        }
    }
    
    [self endTouches];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    // This is only called from gesture recognizers
    // Or when an incoming phone call
    
    [self endTouches];
}

- (void)beginTouches {
    // Disable UIScrollView scrolling
    self.scrollEnabled = NO;
    self.pinchGestureRecognizer.enabled = NO;
    self.panGestureRecognizer.enabled = NO;
}

- (void)endTouches {
    // Reset selected cell
    if (self.selectedView) {
        if ([self.selectedView respondsToSelector:@selector(hideHighlight)]) {
            [self.selectedView performSelector:@selector(hideHighlight)];
        }
        self.selectedView = nil;
    }
    
    self.activeTouchClass = nil;
    
    // Hide selection view
    [self hideSelectionView:YES];
    
    // Reset originalTouchPoint
    self.originalTouchPoint = CGPointMake(-1, -1);
    
    // Remove all touched indices
    [self.touchedIndices removeAllObjects];
    
    // Re-enable scrollview scrolling and gesture detection
    self.scrollEnabled = YES;
    self.pinchGestureRecognizer.enabled = YES;
    self.panGestureRecognizer.enabled = YES;
}

#pragma mark - Target Mode

- (void)toggleTargetMode {
    self.inTargetMode = ~self.inTargetMode;
    
    if (self.inTargetMode) {
        [self.gridView bringSubviewToFront:self.targetView];
    }
    
    CGFloat animateDuration = YES ? 0.2 : 0.0;
    [UIView animateWithDuration:animateDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        // dim screen
        if (self.inTargetMode) {
            self.targetView.alpha = 0.7;
        } else {
            self.targetView.alpha = 0.0;
        }
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - Selection View

- (void)showSelectionViewWithRect:(CGRect)rect animated:(BOOL)animated {
    self.selectionView.frame = rect;
    [self.gridView bringSubviewToFront:self.selectionView];
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

#pragma mark - Data

- (NSDictionary *)exportData {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    // Cells
    NSMutableArray *cellDicts = [NSMutableArray array];
    for (PSGridViewCell *cell in self.cells) {
        NSArray *indices = [NSArray arrayWithArray:[cell.indices allObjects]];
        NSDictionary *content = [NSDictionary dictionaryWithDictionary:cell.content];
        NSDictionary *cellDict = @{@"indices": indices, @"content": content};
        [cellDicts addObject:cellDict];
    }
    [dict setObject:[NSArray arrayWithArray:cellDicts] forKey:@"cells"];
    
    // Tap Targets
    NSMutableArray *targetDicts = [NSMutableArray array];
    for (PSGridViewTarget *target in self.targets) {
        NSArray *indices = [NSArray arrayWithArray:[target.indices allObjects]];
        NSDictionary *action = [NSDictionary dictionaryWithDictionary:target.action];
        NSDictionary *targetDict = @{@"indices": indices, @"action": action};
        [targetDicts addObject:targetDict];
    }
    [dict setObject:targetDicts forKey:@"targets"];
    
    // Page Config TODO
    [dict setObject:[NSNumber numberWithInteger:self.numCols] forKey:@"cols"];
    [dict setObject:[NSNumber numberWithInteger:self.numRows] forKey:@"rows"];
    [dict setObject:[NSNumber numberWithInteger:self.margin] forKey:@"margin"];
    [dict setObject:[self.tileColor hexStringFromColor] forKey:@"backgroundColor"];
    
    return dict;
}

- (void)importData:(NSDictionary *)dict {
    // Page Config
    self.numCols = [[dict objectForKey:@"cols"] integerValue];
    self.numRows = [[dict objectForKey:@"rows"] integerValue];
    self.margin = [[dict objectForKey:@"margin"] floatValue];
    self.backgroundColor = [UIColor colorWithHexString:[dict objectForKey:@"backgroundColor"]];
    
    // Cells
    for (NSDictionary *cellDict in [dict objectForKey:@"cells"]) {
        PSGridViewCell *cell = [[PSGridViewCell alloc] initWithFrame:CGRectZero];
        cell.parentView = self;
        cell.indices = [NSSet setWithArray:[cellDict objectForKey:@"indices"]];
        cell.content = [cellDict objectForKey:@"content"];
        [self.gridView insertSubview:cell belowSubview:self.selectionView];
        [self.cells addObject:cell];
    }
}

#pragma mark - PSGridViewCellDelegate

- (void)gridViewCell:(PSGridViewCell *)gridViewCell didTapWithWithState:(UIGestureRecognizerState)state {
    //    [self editCell:gridViewCell];
}

- (void)gridViewCell:(PSGridViewCell *)gridViewCell didLongPressWithState:(UIGestureRecognizerState)state {
    //    [self removeCell:gridViewCell];
}

#pragma mark - UIScrollViewDelegate

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
    return floorf((self.width - self.numCols * self.margin - self.margin) / self.numCols);
}

- (CGFloat)cellHeight {
    return [self cellWidth];
}

- (NSInteger)rowForIndex:(NSString *)index {
    NSInteger row = [[[index componentsSeparatedByString:@","] objectAtIndex:0] integerValue];
    
    return row;
}

- (NSInteger)colForIndex:(NSString *)index {
    NSInteger col = [[[index componentsSeparatedByString:@","] objectAtIndex:1] integerValue];
    
    return col;
}

// Returns {row,col} index for row/col
- (NSString *)indexForRow:(NSInteger)row col:(NSInteger)col {
    return [NSString stringWithFormat:@"%d,%d", row, col];
}

// Returns row,col pair of indices for a given rect
- (NSSet *)indicesForRect:(CGRect)rect {
    NSMutableSet *indices = [NSMutableSet set];
    
    for (PSGridViewTile *tile in self.tiles) {
        if (CGRectIntersectsRect(rect, tile.frame)) {
            [indices addObject:tile.index];
        }
    }
    
    return [NSSet setWithSet:indices];
}

// Returns combined rect for an array of row,col indices
- (CGRect)rectForIndices:(NSSet *)indices {
    CGFloat cellWidth = [self cellWidth];
    CGFloat cellHeight = [self cellHeight];
    
    CGRect cellRect = CGRectNull;
    for (NSString *index in indices) {
        NSInteger row = [[[index componentsSeparatedByString:@","] objectAtIndex:0] integerValue];
        NSInteger col = [[[index componentsSeparatedByString:@","] objectAtIndex:1] integerValue];
        
        CGRect newRect = CGRectMake(col * cellWidth + self.margin * (col + 1), row * cellHeight + self.margin * (row + 1), cellWidth, cellHeight);
        if (CGRectIsNull(cellRect)) {
            cellRect = newRect;
        } else {
            cellRect = CGRectUnion(cellRect, newRect);
        }
    }
    
    return cellRect;
}

// DEPRECATED METHOD
//- (CGRect)rectForIndices:(NSSet *)indices {
//    CGRect rect = CGRectNull;
//    for (NSString *index in indices) {
//        PSGridViewTile *matchingTile = nil;
//        for (PSGridViewTile *tile in self.tiles) {
//            if ([tile.index isEqualToString:index]) {
//                matchingTile = tile;
//            }
//        }
//        
//        if (CGRectIsNull(rect)) {
//            rect = matchingTile.frame;
//        } else {
//            rect = CGRectUnion(rect, matchingTile.frame);
//        }
//    }
//    
//    //    NSLog(@"Rect for Indices %@", NSStringFromCGRect(rect));
//    return rect;
//}

// Returns an array of {row,col} indices for a given cell key
// UNUSED
- (NSArray *)indicesForKey:(NSString *)key {
    return [key componentsSeparatedByString:@"|"];
}

// Returns a cell key for an array of {row,col} indices
// UNUSED
- (NSString *)keyForIndices:(NSArray *)indices {
    return [indices componentsJoinedByString:@"|"];
}

// NOTE: CAN RETURN NIL
// UNUSED
- (NSString *)indexForPoint:(CGPoint)point {
    __block NSString *touchIndex = nil;
    for (PSGridViewTile *tile in self.tiles) {
        if (CGRectContainsPoint(tile.frame, point)) {
            touchIndex = tile.index;
            break;
        }
    }
    
    return touchIndex;
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

@end
