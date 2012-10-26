//
//  PSTextField.m
//  PSKit
//
//  Created by Peter Shih on 7/11/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSTextField.h"

@interface PSTextField ()

@property (nonatomic, assign) CGSize margins;

- (CGRect)fieldRectWithMargins:(CGSize)margins;

@end

@implementation PSTextField

- (id)initWithFrame:(CGRect)frame withMargins:(CGSize)margins {
    self.margins = margins;
    return [self initWithFrame:frame];
}

- (CGRect)fieldRectWithMargins:(CGSize)margins {
    CGFloat leftWidth = self.margins.width;
    if (self.leftView) {
        leftWidth += self.leftView.width;
    }
    
    CGFloat rightWidth = self.margins.width;
    if (self.rightView) {
        rightWidth += self.rightView.width;
    } else if ([self clearButtonRectForBounds:[self bounds]].size.width > 0 && self.hasText) {
        rightWidth += [self clearButtonRectForBounds:[self bounds]].size.width;
    }
    
    CGFloat textWidth = self.width - leftWidth - rightWidth - margins.width * 2;
    CGFloat textHeight = self.height - margins.height * 2;
    CGFloat left = leftWidth + margins.width;
    CGFloat top = self.margins.height;
    
    CGRect frame = CGRectMake(left, top, textWidth, textHeight);
    
    NSLog(@"%@", NSStringFromCGRect(frame));
    return frame;
}

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
    return [self fieldRectWithMargins:self.margins];
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    return [self fieldRectWithMargins:self.margins];
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self fieldRectWithMargins:self.margins];
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    CGFloat width = self.leftView.width;
    CGFloat height = self.leftView.height;
    
    CGRect leftFrame = CGRectMake(self.margins.width, self.margins.height, width, height);

    return leftFrame;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
    CGFloat width = self.rightView.width;
    CGFloat height = self.rightView.height;
    
    CGRect rightFrame = CGRectMake(self.width - self.margins.width, self.margins.height, width, height);
    
    return rightFrame;
}

// This overrides the default image for a clear button
//- (UIButton *)clearButton {
//    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    clearButton.frame = [self clearButtonRectForBounds:self.bounds];
//    [clearButton setImage:[UIImage imageNamed:@"PSKit.bundle/IconClear.png"] forState:UIControlStateNormal];
//    return clearButton;
//}


@end
