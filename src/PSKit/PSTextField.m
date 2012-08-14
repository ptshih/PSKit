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
    CGFloat leftWidth = self.leftView.width;
    CGFloat rightWidth = self.rightView.width;
    
    CGFloat width = self.width - leftWidth - rightWidth;
    CGRect frame = CGRectMake(leftWidth, self.inset.top, width, self.height - self.inset.top - self.inset.bottom);
    
    return frame;
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
    CGRect frame = UIEdgeInsetsInsetRect(self.leftView.bounds, self.inset);
    
    return frame;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
    CGRect frame = UIEdgeInsetsInsetRect(self.rightView.bounds, self.inset);
    
    return frame;
}

// This overrides the default image for a clear button
//- (UIButton *)clearButton {
//    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    clearButton.frame = [self clearButtonRectForBounds:self.bounds];
//    [clearButton setImage:[UIImage imageNamed:@"PSKit.bundle/IconClear.png"] forState:UIControlStateNormal];
//    return clearButton;
//}


@end
