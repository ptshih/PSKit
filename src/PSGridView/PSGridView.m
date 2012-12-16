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
#define SELECTION_OK_BG_COLOR RGBACOLOR(0, 0, 0, 0.5)
#define SELECTION_ERROR_BG_COLOR RGBACOLOR(255.0, 0, 0, 0.7)


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

@property (nonatomic, assign) BOOL shouldCreateCell;
@property (nonatomic, assign) CGRect touchRect;
@property (nonatomic, assign) CGPoint touchOrigin;
@property (nonatomic, assign) PSGridViewCell *touchedCell;
@property (nonatomic, assign) PSGridViewTile *touchedTile;
@property (nonatomic, strong) NSArray *touchedIndices;

@property (nonatomic, strong) NSMutableDictionary *tiles;
@property (nonatomic, strong) NSMutableDictionary *cells;
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
        
        self.shouldCreateCell = NO;
        self.touchRect = CGRectZero;
        self.touchedCell = nil;
        self.touchedTile = nil;
        
        
        self.tiles = [NSMutableDictionary dictionary]; // background tiles
        self.cells = [NSMutableDictionary dictionary]; // active cells
        self.borders = [NSMutableSet set]; // tile borders
        
        // Main grid view
        self.gridView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.gridView];
        
        // Selection view (touch overlay)
        self.selectionView = [[UIView alloc] initWithFrame:CGRectZero];
        self.selectionView.userInteractionEnabled = NO;
        self.selectionView.backgroundColor = SELECTION_OK_BG_COLOR;
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
    
    CGFloat width = self.numCols * [self cellWidth];
    CGFloat height = self.numRows * [self cellHeight];
    self.contentSize = CGSizeMake(width, height);
    self.gridView.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
    
    // Draw Borders
    [self.borders makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.borders removeAllObjects];
    for (int row = 0; row <= self.numRows; row++) {
        CALayer *hBorder = [CALayer layer];
        hBorder.frame = CGRectMake(0, row * [self cellHeight] -0.5, self.gridView.width, 1.0);
        hBorder.backgroundColor = TILE_BORDER_COLOR.CGColor;
        hBorder.rasterizationScale = [UIScreen mainScreen].scale;
        hBorder.shouldRasterize = YES;
        [self.gridView.layer addSublayer:hBorder];
        [self.borders addObject:hBorder];
    }
    
    for (int col = 0; col <= self.numCols; col++) {
        CALayer *vBorder = [CALayer layer];
        vBorder.frame = CGRectMake(col * [self cellWidth] -0.5, 0, 1.0, self.gridView.height);
        vBorder.backgroundColor = TILE_BORDER_COLOR.CGColor;
        vBorder.rasterizationScale = [UIScreen mainScreen].scale;
        vBorder.shouldRasterize = YES;
        [self.gridView.layer addSublayer:vBorder];
        [self.borders addObject:vBorder];
    }
    
    // Zoom scale
    self.minimumZoomScale = isDeviceIPad() ? (2.0 / 3.0) : 0.25;
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
    return floorf(self.width / self.numCols);
}

- (CGFloat)cellHeight {
    return 96.0;
    return [self cellWidth] * (3.0 / 4.0);
}

// Returns an array of {row,col} indices for a given cell key
- (NSArray *)indicesForKey:(NSString *)key {
    return [key componentsSeparatedByString:@"|"];
}

// Returns a cell key for an array of {row,col} indices
- (NSString *)keyForIndices:(NSArray *)indices {
    return [indices componentsJoinedByString:@"|"];
}

// Returns row,col pair of indices for a given rect
- (NSArray *)indicesForRect:(CGRect)rect {
    NSMutableArray *indices = [NSMutableArray array];
    
    [self.tiles enumerateKeysAndObjectsUsingBlock:^(NSString *index, PSGridViewTile *tile, BOOL *stop) {
        if (CGRectIntersectsRect(rect, tile.frame)) {
            [indices addObject:index];
        }
    }];
    
    return [NSArray arrayWithArray:indices];
}

// Returns rect for an array of row,col indices
- (CGRect)rectForIndices:(NSArray *)indices {
    CGRect rect = CGRectNull;
    for (NSString *index in indices) {
        NSInteger row = [[[index componentsSeparatedByString:@","] objectAtIndex:0] integerValue];
        NSInteger col = [[[index componentsSeparatedByString:@","] objectAtIndex:1] integerValue];
        CGRect indexRect = CGRectMake(col * [self cellWidth], row * [self cellHeight], [self cellWidth], [self cellHeight]);
        if (CGRectIsNull(rect)) {
            rect = indexRect;
        } else {
            rect = CGRectUnion(rect, indexRect);
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

// Returns index for row/col
- (NSString *)indexForRow:(NSInteger)row col:(NSInteger)col {
    return [NSString stringWithFormat:@"%d,%d", row, col];
}

// UNUSED
- (NSString *)coordinateForIndex:(NSString *)index {
    NSInteger row = [[[index componentsSeparatedByString:@","] objectAtIndex:0] integerValue];
    NSInteger col = [[[index componentsSeparatedByString:@","] objectAtIndex:1] integerValue];
    
    return [NSString stringWithFormat:@"%d,%d", row, col];
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
    // Create base tiles
    for (int row = 0; row < self.numRows; row++) {
        for (int col = 0; col < self.numCols; col++) {
            PSGridViewTile *tileView = [self.tiles objectForKey:[self indexForRow:row col:col]];
            CGRect tileRect = CGRectMake(col * [self cellWidth], row * [self cellHeight], [self cellWidth], [self cellHeight]);;
            tileView.frame = tileRect;
        }
    }
    
    // Add existing cells back
    [self.cells enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        PSGridViewCell *cell = obj;
        NSArray *indices = [key componentsSeparatedByString:@"|"];
        CGRect indicesRect = [self rectForIndices:indices];
        
        cell.frame = indicesRect;
        [self.gridView addSubview:cell];
    }];
}

#pragma mark - Cells

- (void)addCellWithRect:(CGRect)rect {
    // Configure the cell, if successful then add it
    [UIActionSheet actionSheetWithTitle:@"Add/Edit Content" message:nil destructiveButtonTitle:nil buttons:@[@"Text", @"Image URL", @"Color"] showInView:self onDismiss:^(int buttonIndex, NSString *textInput) {
        PSGridViewCell *cell = [[PSGridViewCell alloc] initWithFrame:rect];
        [self.gridView insertSubview:cell belowSubview:self.selectionView];
        
        // Add new key
        [self.cells setObject:cell forKey:[self keyForIndices:self.touchedIndices]];
        
        // Setup gesture recognizer
        if ([cell.gestureRecognizers count] == 0) {
            PSGridViewTapGestureRecognizer *gr = [[PSGridViewTapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectCell:)];
            gr.delegate = self;
            [cell addGestureRecognizer:gr];
            
            PSGridViewLongPressGestureRecognizer *lpgr = [[PSGridViewLongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressCell:)];
            lpgr.delegate = self;
            [cell addGestureRecognizer:lpgr];
            
            cell.userInteractionEnabled = YES;
        }
        
        // Load with configuration
        switch (buttonIndex) {
            case 0: {
                [UIAlertView alertViewWithTitle:@"Enter Text" style:UIAlertViewStylePlainTextInput message:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Ok"] onDismiss:^(int buttonIndex, NSString *textInput){
                    NSLog(@"%@", textInput);
                    
                    if (textInput.length > 0) {
                        [cell loadText:textInput];
                    }
                } onCancel:^{
                }];
                break;
            }
            case 1: {
                [UIAlertView alertViewWithTitle:@"Image" style:UIAlertViewStylePlainTextInput message:@"URL" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Ok"] onDismiss:^(int buttonIndex, NSString *textInput){
                    NSLog(@"%@", textInput);
                    
                    if (textInput.length > 0) {
                        [cell loadImageAtURL:[NSURL URLWithString:textInput]];
                    }
                } onCancel:^{
                }];
                break;
            }
            case 2: {
                [cell loadColor:TEXTURE_DARK_LINEN];
                break;
            }
            default:
                break;
        }
        [self endTouches];
    } onCancel:^{
        [self endTouches];
    }];
}

// Public
- (void)editCell:(PSGridViewCell *)cell {
    [UIActionSheet actionSheetWithTitle:@"Add/Edit Content" message:nil destructiveButtonTitle:nil buttons:@[@"Text", @"Image URL", @"Color"] showInView:self onDismiss:^(int buttonIndex, NSString *textInput) {
        
        // Load with configuration
        switch (buttonIndex) {
            case 0: {
                [UIAlertView alertViewWithTitle:@"Enter Text" style:UIAlertViewStylePlainTextInput message:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Ok"] onDismiss:^(int buttonIndex, NSString *textInput){
                    NSLog(@"%@", textInput);
                    
                    if (textInput.length > 0) {
                        [cell loadText:textInput];
                    }
                } onCancel:^{
                }];
                break;
            }
            case 1: {
                [UIAlertView alertViewWithTitle:@"Image" style:UIAlertViewStylePlainTextInput message:@"URL" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Ok"] onDismiss:^(int buttonIndex, NSString *textInput){
                    NSLog(@"%@", textInput);
                    
                    if (textInput.length > 0) {
                        [cell loadImageAtURL:[NSURL URLWithString:textInput]];
                    }
                } onCancel:^{
                }];
                break;
            }
            case 2: {
                [cell loadColor:TEXTURE_DARK_LINEN];
                break;
            }
            default:
                break;
        }
    } onCancel:^{
    }];
}

#pragma mark - Selection View
- (void)showSelectionView:(BOOL)animated {
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.selectionView.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideSelectionView:(BOOL)animated {
    CGFloat animateDuration = animated ? 0.2 : 0.0;
    [UIView animateWithDuration:animateDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.selectionView.alpha = 0.0;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - Gesture Recognizer

- (void)didSelectCell:(UITapGestureRecognizer *)gestureRecognizer {
    if (self.gridViewDelegate && [self.gridViewDelegate respondsToSelector:@selector(gridView:didSelectCell:atIndices:)]) {
        [self.gridViewDelegate gridView:self didSelectCell:(PSGridViewCell *)gestureRecognizer.view atIndices:[self indicesForRect:gestureRecognizer.view.frame]];
    }
}

- (void)didLongPressCell:(UILongPressGestureRecognizer *)gestureRecognizer {
    PSGridViewCell *cell = (PSGridViewCell *)gestureRecognizer.view;
    
    // Remove cell
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        cell.alpha = 0.0;
    } completion:^(BOOL finished) {
        [cell removeFromSuperview];
        NSArray *oldIndices = [self indicesForRect:cell.frame];
        [self.cells removeObjectForKey:[self keyForIndices:oldIndices]];
    }];
    
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (![gestureRecognizer isMemberOfClass:[PSGridViewTapGestureRecognizer class]] && ![gestureRecognizer isMemberOfClass:[PSGridViewLongPressGestureRecognizer class]]) return YES;
    
    if ([touch.view isKindOfClass:[PSGridViewCell class]]) {
        return YES;
    } else {
        return NO;
    }
}


#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    [super touchesBegan:touches withEvent:event];
    [self touchesBeganOrMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    [super touchesMoved:touches withEvent:event];
    [self touchesBeganOrMoved:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
//    [super touchesCancelled:touches withEvent:event];
    [self touchesEndedOrCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    [super touchesEnded:touches withEvent:event];
    
    // We are creating a new cell
    if (self.shouldCreateCell) {
        self.shouldCreateCell = NO;
        // This is the new proposed cell rect
        CGRect newCellRect = [self rectForIndices:self.touchedIndices];
        
        // Add a new cell
        [self addCellWithRect:newCellRect];
    } else {
        [self endTouches];
    }
}

- (void)touchesBeganOrMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"Began or Moved: %@", touches);
//    NSLog(@"x: %f, y: %f", [[touches anyObject] locationInView:self.gridView].x, [[touches anyObject] locationInView:self.gridView].y);

    [self beginTouches];
    
    // Detect number of touches
    if (touches.count == 1) {
        // Detect if a tile has been touched for the first time
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInView:self.gridView];
        if (!self.touchedTile && [touch.view isKindOfClass:[PSGridViewTile class]]) {
            self.touchedTile = (PSGridViewTile *)touch.view;
            self.touchOrigin = touchPoint;
        }
        
        // If the touch isnt' on a tile, it is invalid
        if (![touch.view isKindOfClass:[PSGridViewTile class]]) {
            return;
        }
    } else if (touches.count == 2) {
        // Figure out if we touched an existing cell
        for (UITouch *touch in touches) {
            if (!self.touchedCell && [touch.view isKindOfClass:[PSGridViewCell class]]) {
                self.touchedCell = (PSGridViewCell *)touch.view;
            }
            
            // If the touch isnt' on a cell, it is invalid
            if (![touch.view isKindOfClass:[PSGridViewCell class]]) {
                return;
            }
        }
    } else {
        // Do not respond to touches that are more than 2
        return;
    }
    
    // Calculate touch rectangle
    CGPoint p0, p1;
    if (self.touchedTile) {
        // Find the touch rectangle from origin to destination
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInView:self.gridView];
        p0 = self.touchOrigin;
        p1 = touchPoint;
    } else if (self.touchedCell) {
        // Calculate touch rectangle from all touches
        NSArray *allTouches = [touches allObjects];
        p0 = [[allTouches objectAtIndex:0] locationInView:self.gridView];
        p1 = [[allTouches objectAtIndex:1] locationInView:self.gridView];
    } else {
        // Did not touch a valid object
        return;
    }
    
    CGRect touchRect = CGRectMake(MIN(p0.x, p1.x), MIN(p0.y, p1.y), fabsf(p0.x - p1.x), fabsf(p0.y - p1.y));
    self.touchRect = touchRect; // selection area
    self.touchedIndices = [self indicesForRect:touchRect];
    
    
    // Check to see if the current touch rectangle conflicts with any existing cells
    __block BOOL hasConflict = NO;
    [self.cells enumerateKeysAndObjectsUsingBlock:^(id key, PSGridViewCell *cell, BOOL *stop) {
        // Only conflict with other cells, not itself
        if (![cell isEqual:self.touchedCell]) {
            NSArray *cellIndices = [self indicesForKey:key];
            CGRect cellIndicesRect = [self rectForIndices:cellIndices];
            
            // If current touch area intersects an existing cell, we have a conflict
            if (CGRectIntersectsRect(touchRect, cellIndicesRect)) {
                hasConflict = YES;
                *stop = YES;
            }
        }
    }];
    
    
    if (!hasConflict) {
        // This is the new proposed cell rect
        CGRect newCellRect = [self rectForIndices:self.touchedIndices];
        
        // Show selection view overlay
        self.selectionView.frame = newCellRect;
        [self.gridView bringSubviewToFront:self.selectionView];
        self.selectionView.backgroundColor = SELECTION_OK_BG_COLOR;
        if (self.selectionView.alpha != 1.0) {
            [self showSelectionView:YES];
        }
        
        if (self.touchedTile) {
            // We are creating a new cell
            self.shouldCreateCell = YES;
        } else if (self.touchedCell) {
            // We are modifying an existing cell
            // Remove old key
            NSArray *oldIndices = [self indicesForRect:self.touchedCell.frame];
            [self.cells removeObjectForKey:[self keyForIndices:oldIndices]];
            
            // if new rect is wholly resides in existing rect, this is a shrink
            if (CGRectContainsRect(self.touchedCell.frame, newCellRect)) {
                self.touchedCell.frame = newCellRect;
            } else {
                self.touchedCell.frame = CGRectUnion(newCellRect, self.touchedCell.frame);
            }
            
            // Add new key
            NSArray *newIndices = [self indicesForRect:self.touchedCell.frame];
            [self.cells setObject:self.touchedCell forKey:[self keyForIndices:newIndices]];
        } else {
            // Did not touch a valid object
            return;
        }
    } else {
        // Conflicting cell, No-Op
        self.selectionView.backgroundColor = SELECTION_ERROR_BG_COLOR;
        return;
    }
}

- (void)touchesEndedOrCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self endTouches];
}

- (void)beginTouches {
    // Disable UIScrollView scrolling
    self.scrollEnabled = NO;
    self.pinchGestureRecognizer.enabled = NO;
    self.panGestureRecognizer.enabled = NO;
    
    // Default cell creation to NO;
    self.shouldCreateCell = NO;
}

- (void)endTouches {
    // Hide selection view
    [self hideSelectionView:YES];
    
    // Reset touched cell and tile
    self.touchedCell = nil;
    self.touchedTile = nil;
    
    // Re-enable scrollview scrolling and gesture detection
    self.scrollEnabled = YES;
    self.pinchGestureRecognizer.enabled = YES;
    self.panGestureRecognizer.enabled = YES;
}

@end
