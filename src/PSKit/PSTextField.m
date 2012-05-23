//
//  PSTextField.m
//  PSKit
//
//  Created by Peter Shih on 7/11/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSTextField.h"

@interface PSTextField ()

- (CGRect)rectWithInset:(UIEdgeInsets)inset;

@end

@implementation PSTextField

@synthesize
inset = _inset;

- (id)initWithFrame:(CGRect)frame withInset:(UIEdgeInsets)inset {
    self.inset = inset;
    return [self initWithFrame:frame];
}

- (CGRect)rectWithInset:(UIEdgeInsets)inset {
    CGRect clearViewRect = [self clearButtonRectForBounds:self.bounds];
    CGRect rightViewRect = [self rightViewRectForBounds:self.bounds];
    CGRect leftViewRect = [self leftViewRectForBounds:self.bounds];
    CGFloat rightMargin = MAX(clearViewRect.size.width, rightViewRect.size.width);
    CGFloat leftMargin = leftViewRect.size.width;
    
    return UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(inset.top, inset.left + leftMargin, inset.bottom, inset.right + rightMargin));
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
    CGFloat dim = bounds.size.height - self.inset.top * 2;
    return CGRectMake(self.inset.left, self.inset.top, dim, dim);
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
    CGFloat dim = bounds.size.height - self.inset.top * 2;
    return CGRectMake(self.width - self.inset.right - dim, self.inset.top, dim, dim);
}

// This overrides the default image for a clear button
//- (UIButton *)clearButton {
//    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    clearButton.frame = [self clearButtonRectForBounds:self.bounds];
//    [clearButton setImage:[UIImage imageNamed:@"PSKit.bundle/IconClear.png"] forState:UIControlStateNormal];
//    return clearButton;
//}


@end
