//
//  PSYouTubeView.m
//  PSKit
//
//  Created by Peter on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSYouTubeView.h"

static NSString *kYouTubeEmbedHTML = @"<html><head>"
"<meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = 320\"/></head>"
"<body style=\"background:#000000;margin:0px\">"
"<div><object width=\"320\" height=\"240\">"
"<param name=\"wmode\" value=\"transparent\"></param>"
"<embed src=\"%@\""
"type=\"application/x-shockwave-flash\" wmode=\"transparent\" width=\"320\" height=\"240\"></embed>"
"</object></div></body></html>";

@interface PSYouTubeView ()

- (UIButton *)findButtonInView:(UIView *)view;

@end

@implementation PSYouTubeView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
    }
    return self;
}

- (void)loadYouTubeWithSource:(NSString *)source {
    NSString *htmlString = [NSString stringWithFormat:kYouTubeEmbedHTML, source];
    [self loadHTMLString:htmlString baseURL:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    UIButton *b = [self findButtonInView:webView];
    [b sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (UIButton *)findButtonInView:(UIView *)view {
    UIButton *button = nil;
    
    if ([view isMemberOfClass:[UIButton class]]) {
        return (UIButton *)view;
    }
    
    if (view.subviews && [view.subviews count] > 0) {
        for (UIView *subview in view.subviews) {
            button = [self findButtonInView:subview];
            if (button) return button;
        }
    }
    return button;
}

@end
