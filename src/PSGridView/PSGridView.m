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




@interface PSGridView ()

@property (nonatomic, assign) NSInteger numCols;
@property (nonatomic, assign) NSInteger numRows;

@property (nonatomic, assign) UIInterfaceOrientation orientation;
@property (nonatomic, assign, readwrite) CGFloat lastWidth;
@property (nonatomic, assign, readwrite) CGFloat lastOffset;
@property (nonatomic, assign, readwrite) CGFloat offsetThreshold;

@property (nonatomic, assign) BOOL shouldCreateCell;
@property (nonatomic, assign) CGRect touchRect;
@property (nonatomic, assign) PSGridViewCell *touchedCell;
@property (nonatomic, strong) NSArray *touchedIndices;
@property (nonatomic, strong) NSMutableSet *activeTouches;

@property (nonatomic, strong) NSMutableArray *tiles;
@property (nonatomic, strong) NSMutableDictionary *cells;

@property (nonatomic, strong) UIView *selectionView;
    
@end

@implementation PSGridView

#pragma mark - Init/Memory

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.alwaysBounceVertical = YES;
        self.multipleTouchEnabled = YES;
        
        self.backgroundColor = [UIColor whiteColor];

        self.numCols = 4;
        self.numRows = 8;
        
        self.lastOffset = 0.0;
        self.offsetThreshold = floorf(self.height / 4.0);
        
        self.shouldCreateCell = NO;
        self.touchRect = CGRectZero;
        self.touchedCell = nil;
        
        self.activeTouches = [NSMutableSet set];
        
        self.tiles = [NSMutableArray array];
        self.cells = [NSMutableDictionary dictionary]; // active cells
        
        self.selectionView = [[UIView alloc] initWithFrame:CGRectZero];
        self.selectionView.userInteractionEnabled = NO;
        self.selectionView.backgroundColor = RGBACOLOR(0, 0, 0, 0.5);
        self.selectionView.alpha = 0.0;
        [self addSubview:self.selectionView];
    }
    
    return self;
}

#pragma mark - Helpers

- (CGFloat)cellDim {
    return floorf(self.width / self.numCols);
}

// Returns row,col pair of indices for a given rect
- (NSArray *)indicesForRect:(CGRect)rect {
    NSMutableArray *indices = [NSMutableArray array];
//    CGFloat dim = [self cellDim];
    
    int i = 0;
    for (UIView *tile in self.tiles) {
        if (CGRectIntersectsRect(rect, tile.frame)) {
            [indices addObject:[self indexForPosition:i]];
        }
        i++;
    }
    
//    CGFloat left, right, top, bottom;
//    
//    left = rect.origin.x;
//    right = rect.origin.x + rect.size.width;
//    top = rect.origin.y;
//    bottom = rect.origin.y + rect.size.height;
//    
//    NSInteger leftCol = (NSInteger)(left / dim);
//    NSInteger rightCol = (NSInteger)(right / dim);
//    NSInteger topRow = (NSInteger)(top / dim);
//    NSInteger bottomRow = (NSInteger)(bottom / dim);
//    
//    NSLog(@"%d, %d, %d, %d", leftCol, rightCol, topRow, bottomRow);
//    
//    for (int i = topRow; i <= bottomRow; i++) {
//        for (int j = leftCol; j <= rightCol; j++) {
//            [indices addObject:[NSString stringWithFormat:@"%d,%d", i, j]]; // row,col
//        }
//    }
    
//    NSLog(@"Indices: %@ for Rect: %@", indices, NSStringFromCGRect(rect));
    
    return [NSArray arrayWithArray:indices];
}

// Returns rect for an array of row,col indices
- (CGRect)rectForIndices:(NSArray *)indices {
    CGFloat dim = [self cellDim];
    CGRect rect = CGRectNull;
    for (NSString *index in indices) {
        NSInteger row = [[[index componentsSeparatedByString:@","] objectAtIndex:0] integerValue];
        NSInteger col = [[[index componentsSeparatedByString:@","] objectAtIndex:1] integerValue];
        CGRect indexRect = CGRectMake(col * dim, row * dim, dim, dim);
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
- (NSInteger)positionForIndex:(NSString *)index {
    NSInteger row = [[[index componentsSeparatedByString:@","] objectAtIndex:0] integerValue];
    NSInteger col = [[[index componentsSeparatedByString:@","] objectAtIndex:1] integerValue];
    
    return (row * self.numCols) + col;
}

// Returns col/row pair for position
- (NSString *)indexForPosition:(NSInteger)index {
    NSInteger col = index % self.numCols;
    NSInteger row = index / self.numCols;
    
    return [NSString stringWithFormat:@"%d,%d", row, col];
}

#pragma mark - Draw

//- (void)drawRect:(CGRect)rect {
//    [super drawRect:rect];
//    
//    CGFloat dim = [self cellDim];
//
//    CGContextRef context = UIGraphicsGetCurrentContext();
//
//    CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);
//    CGContextSetLineWidth(context, 1.0);
//
//    // Draw vertical lines
//    for (int i = 1; i < self.numCols; i++) {
//        CGContextMoveToPoint(context, i * dim, 0); //start at this point
//        CGContextAddLineToPoint(context, i * dim, self.height); //draw to this point
//    }
//    
//    // Draw horizontal lines
//    for (int j = 1; j < self.numRows; j++) {
//        CGContextMoveToPoint(context, 0, j * dim); //start at this point
//        CGContextAddLineToPoint(context, self.width, j * dim); //draw to this point
//    }
//
//    CGContextStrokePath(context);
//}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (self.orientation != orientation) {
        self.orientation = orientation;
        // Recalculates layout
        [self relayoutCells];
    } else if(self.lastWidth != self.width) {
        // Recalculates layout
        [self relayoutCells];
    } else {
        // Recycles cells
        CGFloat diff = fabsf(self.lastOffset - self.contentOffset.y);
        
        if (diff > self.offsetThreshold) {
            self.lastOffset = self.contentOffset.y;
            
//            [self removeAndAddCellsIfNecessary];
        }
    }
    
    self.lastWidth = self.width;
}

- (void)relayoutCells {
    CGFloat dim = [self cellDim];
    CGFloat height = self.numRows * dim;
    
    // Create base tiles
    [self.tiles makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.tiles removeAllObjects];
    for (int row = 0; row < self.numRows; row++) {
        for (int col = 0; col < self.numCols; col++) {
            CGRect tileRect = CGRectMake(col * dim, row * dim, dim, dim);;
            UIView *tileView = [[UIView alloc] initWithFrame:tileRect];
            tileView.multipleTouchEnabled = YES;
            tileView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
            tileView.layer.borderWidth = 0.5;
            tileView.backgroundColor = [UIColor whiteColor];
//            tileView.backgroundColor = RGBCOLOR(arc4random() % 255, arc4random() % 255, arc4random() % 255);
            [self addSubview:tileView];
            [self.tiles addObject:tileView];
        }
    }
    
    // Add existing cells back
    [self.cells enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        PSGridViewCell *cell = obj;
        NSArray *indices = [key componentsSeparatedByString:@"|"];
        CGRect indicesRect = [self rectForIndices:indices];
        
        cell.frame = indicesRect;
        [self addSubview:cell];
    }];
    
    self.contentSize = CGSizeMake(self.width, height);
}


#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesBeganOrMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesBeganOrMoved:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEndedOrCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEndedOrCancelled:touches withEvent:event];
}

- (void)touchesBeganOrMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"Began or Moved: %@", touches);
//    UITouch *touch = [touches anyObject];
//    CGPoint touchPoint = [touch locationInView:self];

    
    // If 2 touches detected on a single view (either tile or cell), we can do either of 2 things
    // 1: Create a new cell
    // 2: Resize an existing cell
    if (touches.count == 2) {
        // Disable UIScrollView scrolling
        self.scrollEnabled = NO;
        
        // These touches are active
        [self.activeTouches unionSet:touches];
        
        // Figure out if we touched an existing cell
        for (UITouch *touch in touches) {
            if ([touch.view isKindOfClass:[PSGridViewCell class]]) {
                self.touchedCell = (PSGridViewCell *)touch.view;
            }
        }
        
        // Calculate touch rectangle and find touched indices
        NSArray *allTouches = [touches allObjects];
        CGPoint p0 = [[allTouches objectAtIndex:0] locationInView:self];
        CGPoint p1 = [[allTouches objectAtIndex:1] locationInView:self];
        
        CGRect touchRect = CGRectMake(MIN(p0.x, p1.x), MIN(p0.y, p1.y), fabsf(p0.x - p1.x), fabsf(p0.y - p1.y));
        
        self.touchRect = touchRect; // selection area
        self.touchedIndices = [self indicesForRect:touchRect];
        
        // Check to see if the current touch rectangle conflicts with any existing cells
        __block BOOL hasConflict = NO;
        [self.cells enumerateKeysAndObjectsUsingBlock:^(id key, PSGridViewCell *cell, BOOL *stop) {
            // Only conflict with other cells, not itself
            if (![cell isEqual:self.touchedCell]) {
                NSArray *cellIndices = [key componentsSeparatedByString:@"|"];
                CGRect cellIndicesRect = [self rectForIndices:cellIndices];
                
                // If current touch area intersects an existing cell, we have a conflict
                if (CGRectIntersectsRect(touchRect, cellIndicesRect)) {
                    hasConflict = YES;
                    *stop = YES;
                }
            }
        }];
        
        // If no conflicts
        if (!hasConflict) {
            // This is the new proposed cell rect
            CGRect newCellRect = [self rectForIndices:self.touchedIndices];
            
            // Show selection view
            self.selectionView.frame = newCellRect;
            [self bringSubviewToFront:self.selectionView];
            if (self.selectionView.alpha != 1.0) {
                [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.selectionView.alpha = 1.0;
                } completion:^(BOOL finished) {
                    
                }];
            }
            
            if (self.touchedCell) {
                // If this is an existing cell
                self.shouldCreateCell = NO;
                
                // Remove old key
                NSArray *oldIndices = [self indicesForRect:self.touchedCell.frame];
                [self.cells removeObjectForKey:[oldIndices componentsJoinedByString:@"|"]];
                
                // if new rect is wholly resides in existing rect, this is a shrink
                if (CGRectContainsRect(self.touchedCell.frame, newCellRect)) {
                    self.touchedCell.frame = newCellRect;
                } else {
                    self.touchedCell.frame = CGRectUnion(newCellRect, self.touchedCell.frame);
                }
                
                // Add new key
                NSArray *newIndices = [self indicesForRect:self.touchedCell.frame];
                [self.cells setObject:self.touchedCell forKey:[newIndices componentsJoinedByString:@"|"]];
            } else {
                // If this is a new cell
                self.shouldCreateCell = YES;
            }
        } else {
            self.shouldCreateCell = NO;
        }
    } else {
        NSLog(@"single touch moved");
    }
}

- (void)touchesEndedOrCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = [touches anyObject];
//    CGPoint touchPoint = [touch locationInView:self];
    
    // If we have 2 active touches
    if (self.activeTouches.count == 2) {
        self.scrollEnabled = YES;
        
        // If we should create a new cell
        if (self.shouldCreateCell) {
            self.shouldCreateCell = NO;
            // This is the new proposed cell rect
            CGRect newCellRect = [self rectForIndices:self.touchedIndices];
            
            PSGridViewCell *newCell = [[PSGridViewCell alloc] initWithFrame:newCellRect];
            newCell.backgroundColor = RGBCOLOR(arc4random() % 255, arc4random() % 255, arc4random() % 255);
            [self addSubview:newCell];
            
            // Add new key
            [self.cells setObject:newCell forKey:[self.touchedIndices componentsJoinedByString:@"|"]];
        }
    }
    
    // Hide selection view
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.selectionView.alpha = 0.0;
    } completion:^(BOOL finished) {
        
    }];
    
    // Remove this current touch from activeTouches
    [self.activeTouches minusSet:touches];
    
    // Reset touchedCell
    self.touchedCell = nil;
}

@end
