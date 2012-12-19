//
//  PSGridViewCell.h
//  PSKit
//
//  Created by Peter Shih on 12/14/12.
//
//

#import <UIKit/UIKit.h>

@interface PSGridViewCell : UIView

@property (nonatomic, strong) NSSet *indices;
@property (nonatomic, strong, readonly) NSDictionary *content;

- (void)loadContent:(NSDictionary *)content;

- (void)loadText:(NSString *)text;
- (void)loadImageAtURL:(NSURL *)URL;
- (void)loadColor:(UIColor *)color;
- (void)loadImage:(UIImage *)image;

@end
