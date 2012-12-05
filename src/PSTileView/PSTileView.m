//
//  PSTileView.m
//  Lunchbox
//
//  Created by Peter Shih on 12/3/12.
//
//

#import "PSTileView.h"

static inline NSMutableDictionary * PSTileViewCellForRect(CGRect rect) {
    return [NSMutableDictionary dictionaryWithDictionary:@{@"x" : [NSNumber numberWithFloat:rect.origin.x], @"y" : [NSNumber numberWithFloat:rect.origin.y], @"width" : [NSNumber numberWithFloat:rect.size.width], @"height" : [NSNumber numberWithFloat:rect.size.height]}];
}

static inline CGRect PSTileViewRectForCell(NSMutableDictionary *dict) {
    return CGRectMake([[dict objectForKey:@"x"] floatValue], [[dict objectForKey:@"y"] floatValue], [[dict objectForKey:@"width"] floatValue], [[dict objectForKey:@"height"] floatValue]);
}

static inline NSString * PSTileViewKeyForIndex(NSInteger index) {
    return [NSString stringWithFormat:@"%d", index];
}

static inline NSInteger PSTileViewIndexForKey(NSString *key) {
    return [key integerValue];
}

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
@interface PSTileViewTapGestureRecognizer : UITapGestureRecognizer
@end

@implementation PSTileViewTapGestureRecognizer
@end


@interface PSTileView () <UIGestureRecognizerDelegate>

@property (nonatomic, assign, readwrite) CGFloat lastWidth;
@property (nonatomic, assign, readwrite) NSInteger numCols;
@property (nonatomic, assign) UIInterfaceOrientation orientation;

@property (nonatomic, strong) NSMutableDictionary *reuseableCells;
@property (nonatomic, strong) NSMutableDictionary *visibleCells;
@property (nonatomic, strong) NSMutableArray *cellKeysToRemove;
@property (nonatomic, strong) NSMutableDictionary *indexToRectMap;

- (void)relayoutTiles;

- (void)enqueueReusableCell:(PSTileViewCell *)cell;

/**
 Magic!
 */
- (void)removeAndAddCellsIfNecessary;

@end


@implementation PSTileView

#pragma mark - Init/Memory

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.alwaysBounceVertical = YES;
        
        self.reuseableCells = [NSMutableDictionary dictionary];
        self.visibleCells = [NSMutableDictionary dictionary];
        self.cellKeysToRemove = [NSMutableArray array];
        self.indexToRectMap = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)dealloc {
    // clear delegates
    self.delegate = nil;
    self.tileViewDelegate = nil;
    self.tileViewDataSource = nil;
}

#pragma mark - DataSource

- (void)reloadData {
    [self relayoutTiles];
}

#pragma mark - View

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (self.orientation != orientation) {
        self.orientation = orientation;
        // Recalculates layout
        [self relayoutTiles];
    } else if(self.lastWidth != self.width) {
        // Recalculates layout
        [self relayoutTiles];
    } else {
        // Recycles cells
        [self removeAndAddCellsIfNecessary];
    }
    
    self.lastWidth = self.width;
}

- (void)relayoutTiles {
    // Reset all state
    [self.visibleCells enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        PSTileViewCell *cell = (PSTileViewCell *)obj;
        [self enqueueReusableCell:cell];
    }];
    [self.visibleCells removeAllObjects];
    [self.cellKeysToRemove removeAllObjects];
    [self.indexToRectMap removeAllObjects];
    
    NSInteger numTiles = [self.tileViewDataSource numberOfTilesInTileView:self];
    NSArray *template = [self.tileViewDataSource templateForTileView:self];
    self.numCols = [[template objectAtIndex:0] count];
    
    CGFloat dim = self.width / self.numCols;
    CGFloat height = 0.0;
    CGFloat border = 4.0;
    
    // If no tiles, don't relayout
    if (numTiles > 0) {
        
        NSMutableArray *cells = [NSMutableArray array];
        NSMutableArray *tiles = [NSMutableArray array];
        
        int i = 0;
        int row = 0;
        NSArray *lastRow = nil;
        while (i < numTiles) {
            for (NSArray *tileRow in template) {
                int col = 0;
                NSString *lastType = nil;
                //            PSTileViewCell *lastCell = nil;
                NSMutableDictionary *lastCell = nil;
                
                NSMutableArray *tilesInRow = [NSMutableArray array];
                
                for (NSString *tileType in tileRow) {
                    if ([lastType isEqualToString:tileType]) {
                        // Repeat from same row
                        CGFloat height = [[lastCell objectForKey:@"height"] floatValue];
                        
                        if (height == dim - border || height == dim) {
                            CGFloat width = [[lastCell objectForKey:@"width"] floatValue];
                            width += dim;
                            [lastCell setObject:[NSNumber numberWithFloat:width] forKey:@"width"];
                        }
                        [tilesInRow addObject:lastCell];
                    } else if ([[lastRow objectAtIndex:col] isEqualToString:tileType]) {
                        // Repeat from last row
                        NSMutableDictionary *lastRowCell = [[tiles objectAtIndex:row-1] objectAtIndex:col];
                        
                        CGFloat height = [[lastRowCell objectForKey:@"height"] floatValue] + dim;
                        [lastRowCell setObject:[NSNumber numberWithFloat:height] forKey:@"height"];
                        
                        lastCell = lastRowCell;
                        [tilesInRow addObject:lastRowCell];
                    } else {
                        // Generate a new cell
                        CGRect cellFrame;
                        
                        if (i == numTiles) {
                            // Finished tiling
                            break;
                        } else if (i == numTiles - 1) {
                            // Last tile
                            // Fill the entire row
                            cellFrame = CGRectMake(col * dim, row * dim, self.width - (col * dim), dim);
                        } else {
                            cellFrame = CGRectMake(col * dim, row * dim, dim, dim);
                        }
                        
                        if (col > 0) {
                            cellFrame = UIEdgeInsetsInsetRect(cellFrame, UIEdgeInsetsMake(0, border, 0, 0));
                        }
                        if (row > 0) {
                            cellFrame = UIEdgeInsetsInsetRect(cellFrame, UIEdgeInsetsMake(border, 0, 0, 0));
                        }
                        
                        NSMutableDictionary *cell = PSTileViewCellForRect(cellFrame);
                        
                        [cells addObject:cell];
                        
                        lastCell = cell;
                        [tilesInRow addObject:cell];
                        i++;
                    }
                    
                    lastType = tileType;
                    col++;
                }
                
                [tiles addObject:tilesInRow];
                lastRow = tileRow;
                row++;
                
                height += dim;
                
                if (i == numTiles) break;
            }
        }
        
        // DEBUG
//        NSLog(@"%@", tiles);
//        NSLog(@"%@", cells);
        
        int index = 0;
        for (NSMutableDictionary *cellDict in cells) {
//           cell.backgroundColor = RGBCOLOR(arc4random() % 255, arc4random() % 255, arc4random() % 255);
            
            CGRect cellFrame = PSTileViewRectForCell(cellDict);
            
            NSString *key = PSTileViewKeyForIndex(index);
            // Add to index rect map
            [self.indexToRectMap setObject:NSStringFromCGRect(cellFrame) forKey:key];
            
            index++;
        }
        
//        NSLog(@"%@", self.indexToRectMap);
        
    } else {
        height = self.height;
    }
    
    self.contentSize = CGSizeMake(self.width, height);
    
    [self removeAndAddCellsIfNecessary];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kPSTileViewDidRelayoutNotification object:self];
}

- (void)removeAndAddCellsIfNecessary {
    static NSInteger bufferViewFactor = 3;
    static NSInteger topIndex = 0;
    static NSInteger bottomIndex = 0;
    
    NSInteger numTiles = [self.tileViewDataSource numberOfTilesInTileView:self];
    
    if (numTiles == 0) return;
    
    
    // Find out what rows are visible
    CGRect visibleRect = CGRectMake(self.contentOffset.x, self.contentOffset.y, self.width, self.height);
    
//    NSLog(@"%@", NSStringFromCGRect(visibleRect));
    
    // Remove all rows that are not inside the visible rect
    [self.visibleCells enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        PSTileViewCell *cell = (PSTileViewCell *)obj;
        CGRect cellRect = cell.frame;
        if (!CGRectIntersectsRect(visibleRect, cellRect)) {
            [self enqueueReusableCell:cell];
            [self.cellKeysToRemove addObject:key];
        }
    }];
    
    [self.visibleCells removeObjectsForKeys:self.cellKeysToRemove];
    [self.cellKeysToRemove removeAllObjects];
    
    if ([self.visibleCells count] == 0) {
        topIndex = 0;
        bottomIndex = numTiles;
    } else {
        NSArray *sortedKeys = [[self.visibleCells allKeys] sortedArrayUsingComparator:^(id obj1, id obj2) {
            if ([obj1 integerValue] < [obj2 integerValue]) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if ([obj1 integerValue] > [obj2 integerValue]) {
                return (NSComparisonResult)NSOrderedDescending;
            } else {
                return (NSComparisonResult)NSOrderedSame;
            }
        }];
        topIndex = [[sortedKeys objectAtIndex:0] integerValue];
        bottomIndex = [[sortedKeys lastObject] integerValue];
        
        topIndex = MAX(0, topIndex - (bufferViewFactor * self.numCols));
        bottomIndex = MIN(numTiles, bottomIndex + (bufferViewFactor * self.numCols));
    }
    
    // Add views
    for (NSInteger i = topIndex; i < bottomIndex; i++) {
        NSString *key = PSTileViewKeyForIndex(i);
        CGRect rect = CGRectFromString([self.indexToRectMap objectForKey:key]);
        
        // If view is within visible rect and is not already shown
        if (![self.visibleCells objectForKey:key] && CGRectIntersectsRect(visibleRect, rect)) {
            // Only add views if not visible
            PSTileViewCell *newCell = [self.tileViewDataSource tileView:self cellForItemAtIndex:i];
            newCell.frame = CGRectFromString([self.indexToRectMap objectForKey:key]);
            [self addSubview:newCell];
            
            // Setup gesture recognizer
            if ([newCell.gestureRecognizers count] == 0) {
                PSTileViewTapGestureRecognizer *gr = [[PSTileViewTapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectCell:)];
                gr.delegate = self;
                [newCell addGestureRecognizer:gr];
                newCell.userInteractionEnabled = YES;
            }
            
            [self.visibleCells setObject:newCell forKey:key];
        }
    }
}

#pragma mark - Reusing Views

- (PSTileViewCell *)dequeueReusableCellForClass:(Class)cellClass {
    NSString *identifier = NSStringFromClass(cellClass);
    
    PSTileViewCell *cell = nil;
    if ([self.reuseableCells objectForKey:identifier]) {
        cell = [[self.reuseableCells objectForKey:identifier] anyObject];
        
        if (cell) {
            // Found a reusable view, remove it from the set
            [[self.reuseableCells objectForKey:identifier] removeObject:cell];
        }
    }
    
    return cell;
}

- (void)enqueueReusableCell:(PSTileViewCell *)cell {
    if ([cell respondsToSelector:@selector(prepareForReuse)]) {
        [cell performSelector:@selector(prepareForReuse)];
    }
    cell.frame = CGRectZero;
    
    NSString *identifier = NSStringFromClass([cell class]);
    if (![self.reuseableCells objectForKey:identifier]) {
        [self.reuseableCells setObject:[NSMutableSet set] forKey:identifier];
    }
    
    [[self.reuseableCells objectForKey:identifier] addObject:cell];
    
    [cell removeFromSuperview];
}

#pragma mark - Gesture Recognizer

- (void)didSelectCell:(UITapGestureRecognizer *)gestureRecognizer {
    NSString *rectString = NSStringFromCGRect(gestureRecognizer.view.frame);
    NSArray *matchingKeys = [self.indexToRectMap allKeysForObject:rectString];
    NSString *key = [matchingKeys lastObject];
    if ([gestureRecognizer.view isMemberOfClass:[[self.visibleCells objectForKey:key] class]]) {
        if (self.tileViewDelegate && [self.tileViewDelegate respondsToSelector:@selector(tileView:didSelectCell:atIndex:)]) {
            NSInteger matchingIndex = PSTileViewIndexForKey([matchingKeys lastObject]);
            [self.tileViewDelegate tileView:self didSelectCell:(PSTileViewCell *)gestureRecognizer.view atIndex:matchingIndex];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (![gestureRecognizer isMemberOfClass:[PSTileViewTapGestureRecognizer class]]) return YES;
    
    NSString *rectString = NSStringFromCGRect(gestureRecognizer.view.frame);
    NSArray *matchingKeys = [self.indexToRectMap allKeysForObject:rectString];
    NSString *key = [matchingKeys lastObject];
    
    if ([touch.view isMemberOfClass:[[self.visibleCells objectForKey:key] class]]) {
        return YES;
    } else {
        return NO;
    }
}

@end
