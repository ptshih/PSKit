//
//  PSFacepileView.m
//  Lunchbox
//
//  Created by Peter Shih on 5/15/12.
//  Copyright (c) 2012 Peter Shih. All rights reserved.
//

#import "PSFacepileView.h"

#define IMAGE_SIZE 28.0
#define MARGIN 4.0
#define NUM_FACES 4

@interface PSFacepileView ()

@property (nonatomic, copy) NSArray *faces;
@property (nonatomic, strong) NSMutableArray *faceViews;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation PSFacepileView

@synthesize
faces = _faces,
faceViews = _faceViews,
nameLabel = _nameLabel;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.faceViews = [NSMutableArray array];
        self.nameLabel = [UILabel labelWithStyle:@"facepileLabel"];
        self.nameLabel.hidden = YES;
        [self addSubview:self.nameLabel];
    }
    return self;
}

- (void)prepareForReuse {
    [self.faceViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.faceViews removeAllObjects];
    
    self.nameLabel.text = nil;
    self.nameLabel.hidden = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat top = 0.0;
    CGFloat left = 0.0;
    CGFloat width = self.width;
    CGSize labelSize = CGSizeZero;
    
    // Name Label
    if (!self.nameLabel.hidden) {
        labelSize = [PSStyleSheet sizeForText:self.nameLabel.text width:width style:@"facepileLabel"];
        self.nameLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
        
        top = self.nameLabel.bottom + MARGIN;
    }
    
    NSInteger faceCount = 0;
    for (UIView *faceView in self.faceViews) {
        if (faceCount >= NUM_FACES) {
            // Add a +more bubble
            faceView.frame = CGRectMake(left, top, IMAGE_SIZE, IMAGE_SIZE);
            break;
        } else {
            faceView.frame = CGRectMake(left, top, IMAGE_SIZE, IMAGE_SIZE);
            left = faceView.right + MARGIN;
            faceCount++;
        }
    }
}


- (void)loadWithFaces:(NSArray *)faces shouldShowNames:(BOOL)shouldShowNames {
    self.faces = faces;
    
    if (shouldShowNames) {
        NSString *nameString = [NSString stringWithFormat:@"%@", [[faces valueForKey:@"name"] componentsJoinedByString:@", "]];
        self.nameLabel.text = nameString;
        self.nameLabel.hidden = NO;
    } else {
        self.nameLabel.hidden = YES;
    }
    
    NSInteger faceCount = 0;
    for (NSDictionary *face in faces) {
        if (faceCount >= NUM_FACES) {
            UILabel *moreView = [[UILabel alloc] initWithFrame:CGRectZero];
            [PSStyleSheet applyStyle:@"facepileMoreLabel" forLabel:moreView];
            moreView.backgroundColor = [UIColor colorWithRGBHex:0xd4d1c5];
            moreView.layer.cornerRadius = 3;
            moreView.layer.masksToBounds = YES;
            moreView.text = [NSString stringWithFormat:@"+%d", self.faces.count - faceCount];
            [self.faceViews addObject:moreView];
            [self addSubview:moreView];
            
            break;
        } else {
            PSCachedImageView *imageView = [[PSCachedImageView alloc] initWithFrame:CGRectZero];
            imageView.layer.cornerRadius = 3;
            imageView.layer.masksToBounds = YES;
            [self.faceViews addObject:imageView];
            [self addSubview:imageView];
            faceCount++;
            
            [imageView loadImageWithURL:[NSURL URLWithString:[face objectForKey:@"url"]] cacheType:PSURLCacheTypeSession];
        }
    }
}

+ (CGFloat)heightWithFaces:(NSArray *)faces shouldShowNames:(BOOL)shouldShowNames {
    CGFloat width = [[self class] widthWithFaces:faces shouldShowNames:shouldShowNames];
    CGFloat height = 0.0;
    
    if (shouldShowNames) {
        NSString *nameString = [NSString stringWithFormat:@"%@", [[faces valueForKey:@"name"] componentsJoinedByString:@", "]];
        CGSize labelSize = [PSStyleSheet sizeForText:nameString width:width style:@"facepileLabel"];
        
        height += labelSize.height;
        
        height += MARGIN;
    }
    
    height += IMAGE_SIZE;

    return height;
}

+ (CGFloat)widthWithFaces:(NSArray *)faces shouldShowNames:(BOOL)shouldShowNames {
    NSInteger faceCount = [faces count];
    faceCount = MAX(5, faceCount);
    
    CGFloat width = (IMAGE_SIZE * faceCount) + (MARGIN * (faceCount - 1));
    
    return width;
}

@end
