//
//  PSTextView.m
//  PSKit
//
//  Created by Peter Shih on 3/28/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSTextView.h"

@interface PSTextView ()

@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, assign) UIEdgeInsets paddedInsets;

- (void)updateShouldDrawPlaceholder;
- (void)textChanged:(NSNotification *)notification;

@end

@implementation PSTextView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:self];
        
        self.insets = UIEdgeInsetsMake(-4, -8, 0, 0);
        self.paddedInsets = UIEdgeInsetsMake(0, 0, 8, 0);
        self.contentInset = self.insets;
        
        self.placeholderColor = [UIColor lightGrayColor];
        _shouldDrawPlaceholder = NO;
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (_shouldDrawPlaceholder) {
        [_placeholderColor set];
        [_placeholder drawInRect:CGRectMake(8.0, 8.0, self.frame.size.width - 16.0, self.frame.size.height) withFont:self.font];
    }
}


#pragma mark Setters
- (void)setText:(NSString *)string {
    [super setText:string];
    [self updateShouldDrawPlaceholder];
}


- (void)setPlaceholder:(NSString *)string {
    if ([string isEqual:_placeholder]) {
        return;
    }
    
    _placeholder = string;
    
    [self updateShouldDrawPlaceholder];
}


#pragma mark Private Methods

- (void)updateShouldDrawPlaceholder {
    BOOL prev = _shouldDrawPlaceholder;
    _shouldDrawPlaceholder = self.placeholder && self.placeholderColor && self.text.length == 0;
    
    if (prev != _shouldDrawPlaceholder) {
        [self setNeedsDisplay];
    }
}

- (void)textChanged:(NSNotification *)notificaiton {
    [self updateShouldDrawPlaceholder];    
}

#pragma mark Content Inset/Offset
//- (void)setContentOffset:(CGPoint)s {
//    if(self.tracking || self.decelerating){
//        //initiated by user...
//        self.contentInset = self.insets;
//    } else {
//        
//        float bottomOffset = (self.contentSize.height - self.frame.size.height + self.contentInset.bottom);
//        if(s.y < bottomOffset && self.scrollEnabled){
//            self.contentInset = self.paddedInsets; //maybe use scrollRangeToVisible?
//        }
//        
//    }
//    
//    [super setContentOffset:s];
//}
//
//- (void)setContentInset:(UIEdgeInsets)s {
//    UIEdgeInsets insets = s;
//    
//    if(s.bottom>8) insets.bottom = 0;
//    insets.top = 0;
//    
//    [super setContentInset:insets];
//}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self];
    
    _placeholder = nil;
    _placeholderColor = nil;
    
}
@end
