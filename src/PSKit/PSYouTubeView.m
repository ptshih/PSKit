//
//  PSYouTubeView.m
//  PSKit
//
//  Created by Peter on 2/15/12.
//  Copyright (c) 2012 Peter Shih. All rights reserved.
//

#import "PSYouTubeView.h"

static NSString *kYouTubeEmbedHTML = @"<html><head"
"<meta name=\"viewport\" content=\"width=device-width, maximum-scale=1.0, initial-scale=1.0, user-scalable=no\">"
"</head>"
"<body style=\"background:#000000;margin:0\">"
"<param name=\"wmode\" value=\"transparent\"></param>"
"<iframe id=\"yt\" src=\"%@\" width=\"%0.0f\" height=\"%0.0f\"></iframe>"
"</body></html>";

@interface PSYouTubeView ()

@end

@implementation PSYouTubeView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.scrollView.scrollsToTop = NO;
        self.scrollView.scrollEnabled = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        self.scalesPageToFit = YES;
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        BOOL ok;
        NSError *setCategoryError = nil;
        ok = [audioSession setCategory:AVAudioSessionCategoryPlayback
                                 error:&setCategoryError];
        if (!ok) {
            NSLog(@"%s setCategoryError=%@", __PRETTY_FUNCTION__, setCategoryError);
        }
    }
    return self;
}

- (void)loadYouTubeWithSource:(NSString *)source contentSize:(CGSize)contentSize {
    NSString *htmlString = [NSString stringWithFormat:kYouTubeEmbedHTML, source, contentSize.width, contentSize.height];
    [self loadHTMLString:htmlString baseURL:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
//    NSString *s = [self stringByEvaluatingJavaScriptFromString:<#(NSString *)#>]
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
}

@end
