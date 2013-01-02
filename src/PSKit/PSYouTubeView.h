//
//  PSYouTubeView.h
//  PSKit
//
//  Created by Peter on 2/15/12.
//  Copyright (c) 2012 Peter Shih. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PSYouTubeView : UIWebView <UIWebViewDelegate>

- (void)loadYouTubeWithSource:(NSString *)source contentSize:(CGSize)contentSize;

@end
