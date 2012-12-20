//
//  PSGridViewTarget.h
//  Grid
//
//  Created by Peter Shih on 12/20/12.
//
//

#import <UIKit/UIKit.h>

@interface PSGridViewTarget : UIView

@property (nonatomic, strong) NSSet *indices;
@property (nonatomic, strong) NSDictionary *action;

@end
