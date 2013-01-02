//
//  PSPageView.m
//  Grid
//
//  Created by Peter Shih on 12/19/12.
//
//

#import "PSPageView.h"
#import "UIView+PSKit.h"

@interface PSPageView () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

// Views
@property (nonatomic, strong) UIView *pageView;
@property (nonatomic, strong) UIImageView *pageShadowTop;
@property (nonatomic, strong) UIImageView *pageShadowBottom;

// Models
@property (nonatomic, strong) NSMutableSet *cells;

// Config
@property (nonatomic, assign) NSInteger numCols;
@property (nonatomic, assign) NSInteger numRows;
@property (nonatomic, assign) CGFloat margin;

// State
@property (nonatomic, assign) UIInterfaceOrientation orientation;
@property (nonatomic, assign) CGFloat lastWidth;

@end

@implementation PSPageView

#pragma mark - Init/Memory

- (id)initWithFrame:(CGRect)frame dictionary:(NSDictionary *)dictionary {
    self = [self initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.alwaysBounceVertical = YES;
        self.alwaysBounceHorizontal = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;

        // Views
        self.pageView = [[UIView alloc] initWithFrame:CGRectZero];
        self.pageView.backgroundColor = [UIColor colorWithWhite:0.99 alpha:1.0];
        self.clipsToBounds = NO;
        [self addSubview:self.pageView];
        
        self.pageShadowBottom = [[UIImageView alloc] initWithFrame:CGRectZero image:[[UIImage imageNamed:@"DropShadow"] stretchableImageWithLeftCapWidth:1 topCapHeight:0]];
        self.pageShadowBottom.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.pageView addSubview:self.pageShadowBottom];
        
        self.pageShadowTop = [[UIImageView alloc] initWithFrame:CGRectZero image:[[UIImage imageNamed:@"DropShadowInverted"] stretchableImageWithLeftCapWidth:1 topCapHeight:0]];
        self.pageShadowTop.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.pageView addSubview:self.pageShadowTop];
        
        // Models
        self.cells = [NSMutableSet set]; // active cells
        
        // Config
//        self.backgroundColor = [UIColor whiteColor];
        self.margin = 8.0;
        
        // Import Data
        [self importData:dictionary];

    }
    return self;
}

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
    }
    
    self.lastWidth = self.width;
}

- (void)relayoutCells {
    CGFloat width = self.width;
    CGFloat height = 0.0;
    
    CGFloat top = -1;
    CGFloat bottom = -1;
    
    CGFloat left = -1;
    CGFloat right = -1;
    
    for (PSGridViewCell *cell in self.cells) {
//        NSLog(@"indices: %@", cell.indices);
        
        CGRect cellRect = [self rectForIndices:cell.indices];
        cell.frame = cellRect;
        NSLog(@"%@", NSStringFromCGRect(cell.frame));
        
        if (left == -1) {
            left = cellRect.origin.x;
        } else {
            left = MIN(left, cellRect.origin.x);
        }
        
        if (right == -1) {
            right = cellRect.origin.x + cellRect.size.width;
        } else {
            right = MAX(right, cellRect.origin.x + cellRect.size.width); // find bottom
        }
        
        if (top == -1) {
            top = cellRect.origin.y;
        } else {
            top = MIN(top, cellRect.origin.y); // find top
        }
        
        if (bottom == -1) {
            bottom = cellRect.origin.y + cellRect.size.height;
        } else {
            bottom = MAX(bottom, cellRect.origin.y + cellRect.size.height); // find bottom
        }
        
        [cell loadContent];
    }
    
//    top -= self.margin;
//    left -= self.margin;
    
    for (PSGridViewCell *cell in self.cells) {
        cell.top -= top;
        cell.left -= left;
    }
    bottom -= top;
//    bottom += self.margin;
    right -= left;
//    right += self.margin;
    
    height = bottom;
    width = right;
    
    self.contentSize = CGSizeMake(width, height);
    self.pageView.frame = CGRectMake(0, 0, width, height);
    
    self.pageShadowTop.frame = CGRectMake(0.0, -8.0, self.pageView.width, 8.0);
    self.pageShadowBottom.frame = CGRectMake(0.0, self.pageView.height, self.pageView.width, 8.0);
    
    [self centerSubview:self.pageView forScrollView:self];
}

#pragma mark - Helpers

- (CGFloat)cellWidth {
    CGFloat width = self.width - self.margin * (self.numCols - 1);
    CGFloat cellWidth = width / self.numCols;
    return cellWidth;
}

- (CGFloat)cellHeight {
    return [self cellWidth];
}

- (CGRect)rectForIndices:(NSSet *)indices {
    CGFloat cellWidth = [self cellWidth];
    CGFloat cellHeight = [self cellHeight];
    
    CGRect cellRect = CGRectNull;
    for (NSString *index in indices) {
        NSInteger row = [[[index componentsSeparatedByString:@","] objectAtIndex:0] integerValue];
        NSInteger col = [[[index componentsSeparatedByString:@","] objectAtIndex:1] integerValue];
        
        CGRect newRect = CGRectMake(col * cellWidth + self.margin * (col), row * cellHeight + self.margin * (row), cellWidth, cellHeight);
        if (CGRectIsNull(cellRect)) {
            cellRect = newRect;
        } else {
            cellRect = CGRectUnion(cellRect, newRect);
        }
    }
    
    return cellRect;
}

- (void)centerSubview:(UIView *)subView forScrollView:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark -

- (UIImage *)screenshot {
    UIGraphicsBeginImageContext(self.pageView.bounds.size);
    [self.pageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

#pragma mark -

- (void)importData:(NSDictionary *)dict {
    // Page Config
    self.numCols = [[dict objectForKey:@"cols"] integerValue];
    self.numRows = [[dict objectForKey:@"rows"] integerValue];
    self.margin = [[dict objectForKey:@"margin"] floatValue];
    self.pageView.backgroundColor = [UIColor colorWithHexString:[dict objectForKey:@"backgroundColor"]];
    
    // Cells
    for (NSDictionary *cellDict in [dict objectForKey:@"cells"]) {
        PSGridViewCell *cell = [[PSGridViewCell alloc] initWithFrame:CGRectZero];
        cell.parentView = self;
        cell.indices = [NSSet setWithArray:[cellDict objectForKey:@"indices"]];
        cell.content = [cellDict objectForKey:@"content"];
        [self.pageView addSubview:cell];
        [self.cells addObject:cell];
    }
}

@end
