//
//  PSLabel.h
//  PSKit
//
//  Created by Peter Shih on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSLabel : UILabel

@property (nonatomic, strong) NSString *style;

+ (PSLabel *)labelWithStyle:(NSString *)style;

@end
