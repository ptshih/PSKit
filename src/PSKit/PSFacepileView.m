//
//  PSFacepileView.m
//  Lunchbox
//
//  Created by Peter Shih on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSFacepileView.h"

#define IMAGE_SIZE 30.0
#define MARGIN 4.0
#define NUM_FACES 4

@interface PSFacepileView ()

@property (nonatomic, copy) NSArray *faces;
@property (nonatomic, retain) NSMutableArray *faceViews;

@end

@implementation PSFacepileView

@synthesize
faces = _faces,
faceViews = _faceViews;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.faceViews = [NSMutableArray array];
    }
    return self;
}

- (void)prepareForReuse {
    [self.faceViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.faceViews removeAllObjects];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat top = 0.0;
    CGFloat left = 0.0;
    
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


- (void)loadWithFaces:(NSArray *)faces {
    self.faces = faces;
    
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

+ (CGFloat)heightWithFaces:(NSArray *)faces {
    return IMAGE_SIZE;
}

+ (CGFloat)widthWithFaces:(NSArray *)faces {
    NSInteger faceCount = [faces count];
    faceCount = MIN(5, faceCount);
    
    CGFloat width = (IMAGE_SIZE * faceCount) + (MARGIN * (faceCount - 1));
    
    return width;
}

@end
