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
//#define TILE_BORDER_COLOR [UIColor colorWithRGBHex:0x3a3a3a]
#define TILE_BORDER_COLOR [UIColor colorWithRGBHex:0xffffff]
#define SELECTION_TILE_BG_COLOR RGBACOLOR(0, 0, 0, 0.3)
#define SELECTION_CELL_BG_COLOR RGBACOLOR(0, 0, 255.0, 0.5)
#define SELECTION_ERROR_BG_COLOR RGBACOLOR(255.0, 0, 0, 0.5)
#define SELECTION_TARGET_BG_COLOR RGBACOLOR(0.0, 255.0, 0, 0.5)
#define SELECTION_BORDER_COLOR [UIColor colorWithRGBHex:0x7a7a7a]
#define TARGET_BG_COLOR RGBACOLOR(0.0, 255.0, 0, 0.2)

#define TILE_MARGIN 8.0


// This is the class for the tile background
@interface PSGridViewTile : UIView

@property (nonatomic, strong) NSString *index;

@end

@implementation PSGridViewTile

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        self.multipleTouchEnabled = YES;
        self.backgroundColor = TILE_BG_COLOR;
    }
    return self;
}

@end

// This is the class for the target background
@interface PSGridViewTarget : UIView

@property (nonatomic, strong) NSSet *indices;

@end

@implementation PSGridViewTarget

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        self.multipleTouchEnabled = YES;
        self.backgroundColor = TARGET_BG_COLOR;
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

@property (nonatomic, assign) BOOL shouldCreateOrUpdateCell;
@property (nonatomic, assign) BOOL shouldMoveCell;
@property (nonatomic, assign) BOOL shouldResetCell;
@property (nonatomic, assign) CGRect originalCellRect;
@property (nonatomic, assign) CGPoint originalTouchPoint;
@property (nonatomic, assign) UIView *touchedView;
@property (nonatomic, strong) NSMutableSet *touchedIndices;
@property (nonatomic, strong) NSMutableSet *activeTouches;
@property (nonatomic, strong) NSMutableSet *ignoredTouches;

@property (nonatomic, strong) NSMutableSet *tiles;
@property (nonatomic, strong) NSMutableSet *cells;
@property (nonatomic, strong) NSMutableSet *borders;
@property (nonatomic, strong) NSMutableSet *targets;

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
        self.multipleTouchEnabled = YES;

        self.numCols = 12;
        self.numRows = 24;
        
        self.lastOffset = 0.0;
        self.offsetThreshold = floorf(self.height / 4.0);
        
        self.shouldCreateOrUpdateCell = NO; // determines if cell/tile should be created/modified
        self.shouldMoveCell = NO;
        self.shouldResetCell = NO;
        self.originalCellRect = CGRectZero;
        self.touchedView = nil;
        self.touchedIndices = [NSMutableSet set];
        self.activeTouches = [NSMutableSet set];
        self.ignoredTouches = [NSMutableSet set];
        
        self.tiles = [NSMutableSet set]; // background tiles
        self.cells = [NSMutableSet set]; // active cells
        self.borders = [NSMutableSet set]; // tile borders
        self.targets = [NSMutableSet set]; // tap targets
        
        // Main grid view
        self.gridView = [[UIView alloc] initWithFrame:CGRectZero];
        self.gridView.multipleTouchEnabled = YES;
        self.gridView.backgroundColor = TILE_BORDER_COLOR;
        [self addSubview:self.gridView];
        
        // Selection view (touch overlay)
        self.selectionView = [[UIView alloc] initWithFrame:CGRectZero];
        self.selectionView.userInteractionEnabled = NO;
        self.selectionView.backgroundColor = SELECTION_ERROR_BG_COLOR;
        self.selectionView.layer.borderWidth = 1.0;
        self.selectionView.layer.borderColor = [SELECTION_BORDER_COLOR CGColor];
        self.selectionView.alpha = 0.0;
        [self.gridView addSubview:self.selectionView];
        
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
        
        // Create base tiles
        for (int row = 0; row < self.numRows; row++) {
            for (int col = 0; col < self.numCols; col++) {
                PSGridViewTile *tileView = [[PSGridViewTile alloc] initWithFrame:CGRectZero];
                tileView.index = [self indexForRow:row col:col];
                [self.tiles addObject:tileView];
                [self.gridView addSubview:tileView];
            }
        }
        

        
        // Zoom scale
        self.minimumZoomScale = isDeviceIPad() ? 0.5 : 0.5;
        self.maximumZoomScale = 2.0;
        self.zoomScale = 1.0;
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
    self.zoomScale = 1.0;
    
    // Calculate content size and frame
    CGFloat width = self.numCols * [self cellWidth] + (TILE_MARGIN * self.numCols) + TILE_MARGIN;
    CGFloat height = self.numRows * [self cellHeight] + (TILE_MARGIN * self.numRows) + TILE_MARGIN;
    self.contentSize = CGSizeMake(width, height);
    self.gridView.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
    
    // Layout base tiles
    for (PSGridViewTile *tile in self.tiles) {
        CGFloat row = [self rowForIndex:tile.index];
        CGFloat col = [self colForIndex:tile.index];
        CGRect tileRect = CGRectMake(col * [self cellWidth] + (TILE_MARGIN * col) + TILE_MARGIN, row * [self cellHeight] + (TILE_MARGIN * row) + TILE_MARGIN, [self cellWidth], [self cellHeight]);;
        tile.frame = tileRect;
    }
    
    for (PSGridViewCell *cell in self.cells) {
        CGRect cellRect = [self rectForIndices:cell.indices];
        cell.frame = cellRect;
    }
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
    if (self.gridViewDataSource && [self.gridViewDataSource respondsToSelector:@selector(gridView:configureCell:completionBlock:)]) {
        [self.gridViewDataSource gridView:self configureCell:cell completionBlock:^(BOOL cellConfigured) {
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

- (void)addTargetWithRect:(CGRect)rect {
    PSGridViewTarget *target = [[PSGridViewTarget alloc] initWithFrame:rect];
    target.indices = [self indicesForRect:rect];
    [self.targets addObject:target];
    [self.gridView insertSubview:target belowSubview:self.selectionView];
    
    [self endTouches];
}

#pragma mark - Gesture Recognizer

- (void)didSelectCell:(UITapGestureRecognizer *)gestureRecognizer {
    // unused
}

- (void)didLongPressCell:(UILongPressGestureRecognizer *)gestureRecognizer {
//    NSLog(@"%d", gestureRecognizer.state);
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self editCell:(PSGridViewCell *)gestureRecognizer.view];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (self.activeTouches.count > 0) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - Selection View
- (void)showSelectionView:(BOOL)animated withRect:(CGRect)rect {
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


#pragma mark - Touches

// We are only detecting touches for self.gridView
// All tiles and cells have userInteractionEnabled = NO

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    [self beginTouches];
    
    // Figure out if we touched an existing cell
    for (UITouch *touch in touches) {
        CGPoint touchPoint = [touch locationInView:self.gridView];
        BOOL foundTouch = NO;
        
        // Only allow ONE tile to be touched
        if ([self.touchedView isKindOfClass:[PSGridViewTile class]]) {
            [self.ignoredTouches addObject:touch];
            continue;
        }
        
        // Cell
        for (PSGridViewCell *cell in self.cells) {
            if (CGRectContainsPoint(cell.frame, touchPoint)) {
                // Only allow same cell to be touched by multiple fingers
                if (self.touchedView && ![self.touchedView isEqual:cell]) {
                    [self.ignoredTouches addObject:touch];
                } else {
                    self.touchedView = cell;
                    [self.touchedIndices unionSet:cell.indices];
                    
                    self.originalTouchPoint = touchPoint;
                    self.originalCellRect = cell.frame;
                    
                    [self.activeTouches addObject:touch];
                    
                    self.selectionView.backgroundColor = SELECTION_CELL_BG_COLOR;
                    
                    foundTouch = YES;
                }
                
                break;
            }
        }
        
        if (!foundTouch) {
            // Tile
            for (PSGridViewTile *tile in self.tiles) {
                if (CGRectContainsPoint(tile.frame, touchPoint)) {
                    self.touchedView = tile;
                    [self.touchedIndices addObject:tile.index];
                    
                    self.originalTouchPoint = touchPoint;
                    
                    [self.activeTouches addObject:touch];
                    
                    self.shouldCreateOrUpdateCell = YES;
                    
                    self.selectionView.backgroundColor = SELECTION_TILE_BG_COLOR;
                    
                    foundTouch = YES;
                    break;
                }
            }
        }
        
        NSLog(@"began: %@", self.activeTouches);
        
        // Show selection view overlay
        [self showSelectionView:YES withRect:[self rectForIndices:self.touchedIndices]];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    if (self.touchedView && [self.touchedView isKindOfClass:[PSGridViewTile class]]) {
        // Find the touch rectangle from origin to destination
        for (UITouch *touch in touches) {
            if ([self.ignoredTouches containsObject:touch]) {
                continue;
            }
            
            CGPoint touchPoint = [touch locationInView:self.gridView];
            CGPoint p1, p2;
            p1 = self.originalTouchPoint;
            p2 = touchPoint;
            CGRect touchRect = CGRectMake(MIN(p1.x, p2.x), MIN(p1.y, p2.y), fabsf(p1.x - p2.x), fabsf(p1.y - p2.y));
            NSSet *movedIndices = [self indicesForRect:touchRect];
            
            // This is the new proposed cell rect
            CGRect newCellRect = [self rectForIndices:movedIndices];
            
            // Show selection view overlay
            [self showSelectionView:YES withRect:newCellRect];
            
            // Check to see if the current touch rectangle conflicts with any existing cells
            BOOL hasConflict = NO;
            for (PSGridViewCell *cell in self.cells) {
                // Only conflict with other cells, not itself
                if (![cell isEqual:self.touchedView]) {
                    // If current touch area intersects an existing cell, we have a conflict
                    if (CGRectIntersectsRect(newCellRect, cell.frame)) {
                        hasConflict = YES;
                    }
                }
            }
            
            // No conflict with existing cells
            if (!hasConflict) {
                [self.touchedIndices removeAllObjects];
                [self.touchedIndices unionSet:movedIndices];
                self.selectionView.backgroundColor = SELECTION_TILE_BG_COLOR;
                self.shouldCreateOrUpdateCell = YES;
            } else {
                // Conflicting cell, No-Op
                self.selectionView.backgroundColor = SELECTION_ERROR_BG_COLOR;
                self.shouldCreateOrUpdateCell = NO;
            }
        }
    } else if (self.touchedView && [self.touchedView isKindOfClass:[PSGridViewCell class]] && self.activeTouches.count == 2) {
        // We are now pinching
        NSArray *allActiveTouches = [self.activeTouches allObjects];
        CGPoint p1, p2;
        p1 = [[allActiveTouches objectAtIndex:0] locationInView:self.gridView];
        p2 = [[allActiveTouches objectAtIndex:1] locationInView:self.gridView];
        CGRect touchRect = CGRectMake(MIN(p1.x, p2.x), MIN(p1.y, p2.y), fabsf(p1.x - p2.x), fabsf(p1.y - p2.y));
        NSSet *movedIndices = [self indicesForRect:touchRect];
        
        // This is the new proposed cell rect
        CGRect newCellRect = [self rectForIndices:movedIndices];
        
        // Show selection view overlay
        [self showSelectionView:YES withRect:newCellRect];
        
        // Check to see if the current touch rectangle conflicts with any existing cells
        BOOL hasConflict = NO;
        for (PSGridViewCell *cell in self.cells) {
            // Only conflict with other cells, not itself
            if (![cell isEqual:self.touchedView]) {
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
            if (CGRectContainsRect(self.touchedView.frame, newCellRect)) {
                self.touchedView.frame = newCellRect;
            } else {
                self.touchedView.frame = CGRectUnion(newCellRect, self.touchedView.frame);
            }
            
            [(PSGridViewCell *)self.touchedView setIndices:[self indicesForRect:self.touchedView.frame]];
            self.selectionView.backgroundColor = SELECTION_CELL_BG_COLOR;
            self.shouldCreateOrUpdateCell = NO;
        } else {
            // Conflicting cell, No-Op
            self.selectionView.backgroundColor = SELECTION_ERROR_BG_COLOR;
            self.shouldCreateOrUpdateCell = NO;
        }
    } else if (self.touchedView && [self.touchedView isKindOfClass:[PSGridViewCell class]] && self.activeTouches.count == 1 && 0) {
        // DISABLED UNUSED
        
        // Find the touch rectangle from origin to destination
        for (UITouch *touch in touches) {
            if ([self.ignoredTouches containsObject:touch]) {
                continue;
            }
            
            CGPoint touchPoint = [touch locationInView:self.gridView];
            CGPoint p1, p2;
            p1 = self.originalTouchPoint;
            p2 = touchPoint;
            CGRect touchRect = CGRectMake(MIN(p1.x, p2.x), MIN(p1.y, p2.y), fabsf(p1.x - p2.x), fabsf(p1.y - p2.y));
            NSSet *movedIndices = [self indicesForRect:touchRect];
            
            // This is the new proposed cell rect
            CGRect newCellRect = [self rectForIndices:movedIndices];
            
            // Show selection view overlay
            [self showSelectionView:YES withRect:newCellRect];
            
            // Check to see if the current touch rectangle leaves the area of the cell
            if (CGRectContainsRect(self.touchedView.frame, newCellRect)) {
                self.selectionView.backgroundColor = SELECTION_TARGET_BG_COLOR;
                self.shouldCreateOrUpdateCell = NO;
                [self.touchedIndices removeAllObjects];
                [self.touchedIndices unionSet:movedIndices];
            } else {
                // error
                self.selectionView.backgroundColor = SELECTION_ERROR_BG_COLOR;
                self.shouldCreateOrUpdateCell = NO;
            }
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    // Remove active touches
    [self.activeTouches minusSet:touches];
    
    if (self.activeTouches.count > 0) {
        // If there are still active touches, don't do anything
        return;
    }
    
    for (UITouch *touch in touches) {
        if ([self.ignoredTouches containsObject:touch]) {
            continue;
        }
        
        if (self.shouldCreateOrUpdateCell) {
            // Check to see if the touch has moved too far
            CGPoint p1 = self.originalTouchPoint;
            CGPoint p2 = [touch locationInView:self.gridView];
            CGFloat xDist = (p2.x - p1.x);
            CGFloat yDist = (p2.y - p1.y);
            CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
            NSLog(@"distance: %f", distance);
            
            if ([self.touchedView isKindOfClass:[PSGridViewTile class]]) {
                // new cell
                
                // This is the new proposed cell rect
                CGRect newCellRect = [self rectForIndices:self.touchedIndices];
                
                // Add a new cell
                // Show selection view overlay
                [self addCellWithRect:newCellRect];
            } else if ([self.touchedView isKindOfClass:[PSGridViewCell class]]) {
                // existing cell
                
                // Only edit if the touch hasn't moved outside of the existing cell frame
                if (CGRectContainsPoint(self.touchedView.frame, [touch locationInView:self.gridView])) {
                    [self editCell:(PSGridViewCell *)self.touchedView];
                } else {
                    [self endTouches];
                }
            }
        } else if (self.shouldMoveCell) {
            self.touchedView.frame = [self rectForIndices:self.touchedIndices];
            [(PSGridViewCell *)self.touchedView setIndices:self.touchedIndices];
            [self endTouches];
        } else if (self.shouldResetCell) {
            self.touchedView.frame = self.originalCellRect;
            [self endTouches];
        } else {
            [self endTouches];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    for (UITouch *touch in touches) {
        if ([self.ignoredTouches containsObject:touch]) {
            continue;
        }
    }
    
    // Remove active touches
    [self.activeTouches minusSet:touches];
    
    if (self.activeTouches.count > 0) {
        // If there are still active touches, don't do anything
        return;
    }
    
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
    
    self.shouldCreateOrUpdateCell = NO;
    
    // Reset touched cell and tile
    self.touchedView = nil;
    
    // Remove all touched indices
    [self.touchedIndices removeAllObjects];
    
    // Re-enable scrollview scrolling and gesture detection
    self.scrollEnabled = YES;
    self.pinchGestureRecognizer.enabled = YES;
    self.panGestureRecognizer.enabled = YES;
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
    //    return 96.0;
    //    CGFloat width = self.numCols * [self cellWidth] + (TILE_MARGIN * self.numCols) + TILE_MARGIN;
    //    CGFloat height = self.numRows * [self cellHeight] + (TILE_MARGIN * self.numRows) + TILE_MARGIN;
    return floorf((self.width - self.numCols * TILE_MARGIN - TILE_MARGIN) / self.numCols);
}

- (CGFloat)cellHeight {
    //    return 96.0;
    return [self cellWidth];
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
    for (PSGridViewTile *tile in self.tiles) {
        if (CGRectContainsPoint(tile.frame, point)) {
            touchIndex = tile.index;
            break;
        }
    }
    
    return touchIndex;
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
    CGRect rect = CGRectNull;
    for (NSString *index in indices) {
        PSGridViewTile *matchingTile = nil;
        for (PSGridViewTile *tile in self.tiles) {
            if (tile.index == index) {
                matchingTile = tile;
            }
        }
        
        if (CGRectIsNull(rect)) {
            rect = matchingTile.frame;
        } else {
            rect = CGRectUnion(rect, matchingTile.frame);
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

@end
