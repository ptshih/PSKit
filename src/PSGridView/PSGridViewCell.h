//
//  PSGridViewCell.h
//  PSKit
//
//  Created by Peter Shih on 12/14/12.
//
//

#import <UIKit/UIKit.h>

@interface PSGridViewCell : UIView

- (void)loadText:(NSString *)text;
- (void)loadImageAtURL:(NSURL *)URL;
- (void)loadColor:(UIColor *)color;

@end
