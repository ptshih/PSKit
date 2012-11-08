//
//  PSNewspaperTextView.h
//  Vip
//
//  Created by Peter Shih on 7/5/12.
//  Copyright (c) 2012 Peter Shih. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSNewspaperTextView : UIView

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *fontColor;
@property (nonatomic, assign) CGRect flowAroundRect;

@end
