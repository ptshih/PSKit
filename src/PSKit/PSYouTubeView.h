//
//  PSYouTubeView.h
//  Linsanity
//
//  Created by Peter on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSYouTubeView : UIWebView <UIWebViewDelegate>

- (void)loadYouTubeWithSource:(NSString *)source;

@end
