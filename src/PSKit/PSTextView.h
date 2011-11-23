//
//  PSTextView.h
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 3/28/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PSTextView : UITextView {
  NSString *_placeholder;
  UIColor *_placeholderColor;
  
  BOOL _shouldDrawPlaceholder;
}

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

@end
