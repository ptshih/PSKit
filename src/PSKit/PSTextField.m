//
//  PSTextField.m
//  PSKit
//
//  Created by Peter Shih on 7/11/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSTextField.h"


@implementation PSTextField

@synthesize
inset = _inset;

- (id)initWithFrame:(CGRect)frame withInset:(CGSize)inset {
    self.inset = inset;
    return [self initWithFrame:frame];
}

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
    CGRect clearViewRect = [self clearButtonRectForBounds:bounds];
    CGRect rightViewRect = [self rightViewRectForBounds:bounds];
    CGRect leftViewRect = [self leftViewRectForBounds:bounds];
    CGFloat rightMargin = MAX(clearViewRect.size.width, rightViewRect.size.width);
    CGFloat leftMargin = leftViewRect.size.width;
    
    return UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(self.inset.height, self.inset.width + leftMargin, self.inset.height, self.inset.width + rightMargin));
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    CGRect clearViewRect = [self clearButtonRectForBounds:bounds];
    CGRect rightViewRect = [self rightViewRectForBounds:bounds];
    CGRect leftViewRect = [self leftViewRectForBounds:bounds];
    CGFloat rightMargin = MAX(clearViewRect.size.width, rightViewRect.size.width);
    CGFloat leftMargin = leftViewRect.size.width;
    
    return UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(self.inset.height, self.inset.width + leftMargin, self.inset.height, self.inset.width + rightMargin));
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGRect clearViewRect = [self clearButtonRectForBounds:bounds];
    CGRect rightViewRect = [self rightViewRectForBounds:bounds];
    CGRect leftViewRect = [self leftViewRectForBounds:bounds];
    CGFloat rightMargin = MAX(clearViewRect.size.width, rightViewRect.size.width);
    CGFloat leftMargin = leftViewRect.size.width;
    
    return UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(self.inset.height, self.inset.width + leftMargin, self.inset.height, self.inset.width + rightMargin));
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
