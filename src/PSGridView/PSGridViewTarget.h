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

@property (nonatomic, assign) UIView *parentView;
@property (nonatomic, assign) NSMutableSet *targets;

@end
