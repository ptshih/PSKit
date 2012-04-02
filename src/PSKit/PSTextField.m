//
//  PSTextField.m
//  PSKit
//
//  Created by Peter Shih on 7/11/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSTextField.h"

@interface PSTextField ()

- (CGRect)rectWithInset:(CGSize)inset;

@end

@implementation PSTextField

@synthesize
inset = _inset;

- (id)initWithFrame:(CGRect)frame withInset:(CGSize)inset {
    self.inset = inset;
    return [self initWithFrame:frame];
}

- (CGRect)rectWithInset:(CGSize)inset {
    CGRect clearViewRect = [self clearButtonRectForBounds:self.bounds];
    CGRect rightViewRect = [self rightViewRectForBounds:self.bounds];
    CGRect leftViewRect = [self leftViewRectForBounds:self.bounds];
    CGFloat rightMargin = MAX(clearViewRect.size.width, rightViewRect.size.width);
    CGFloat leftMargin = leftViewRect.size.width;
    
    return UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(inset.height, inset.width + leftMargin, inset.height, inset.width + rightMargin));
}

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
    return [self rectWithInset:self.inset];
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    return [self rectWithInset:self.inset];
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self rectWithInset:self.inset];
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    return CGRectMake(8, floorf((bounds.size.height - 16) / 2), 24, 16);
}

// This overrides the default image for a clear button
- (UIButton *)clearButton {
    UIButton *clearButton = [super clearButton];
    [clearButton setImage:[UIImage imageNamed:@"PSKit.bundle/IconClear.png"] forState:UIControlStateNormal];
    return clearButton;
}


@end
