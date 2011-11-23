//
//  PSRollupView.h
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 6/22/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSRollupView : PSView {
  UIImageView *_backgroundView;
  UIImage *_backgroundImage;
  UILabel *_headerLabel;
  UILabel *_footerLabel;
  UIScrollView *_pictureScrollView;
  NSArray *_pictureURLArray;
  
  CGFloat _desiredHeight;
}

@property (nonatomic, retain) UIImage *backgroundImage;
@property (nonatomic, retain) NSArray *pictureURLArray;
@property (nonatomic, readonly) CGFloat desiredHeight;

- (void)setHeaderText:(NSString *)headerText;
- (void)setFooterText:(NSString *)footerText;

@end
