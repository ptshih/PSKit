//
//  PSTextField.h
//  PSKit
//
//  Created by Peter Shih on 7/11/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PSTextField : UITextField

@property (nonatomic, assign) CGSize inset;

- (id)initWithFrame:(CGRect)frame withInset:(CGSize)inset;

@end
