//
//  PSYouTubeView.m
//  PSKit
//
//  Created by Peter on 2/15/12.
//  Copyright (c) 2012 Peter Shih. All rights reserved.
//

#import "PSYouTubeView.h"

static NSString *kYouTubeEmbedHTML = @"<html>"
"<body style=\"background:#000000;margin:0\">"
"<param name=\"wmode\" value=\"transparent\"></param>"
"<embed id=\"yt\" src=\"%@\""
"type=\"application/x-shockwave-flash\" wmode=\"transparent\" width=\"%0.0f\" height=\"%0.0f\"></embed>"
"</body></html>";

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

- (void)loadYouTubeWithSource:(NSString *)source contentSize:(CGSize)contentSize {
    NSString *htmlString = [NSString stringWithFormat:kYouTubeEmbedHTML, source, contentSize.width, contentSize.height];
    [self loadHTMLString:htmlString baseURL:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    UIButton *b = [self findButtonInView:webView];
//    [b sendActionsForControlEvents:UIControlEventTouchUpInside];
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
