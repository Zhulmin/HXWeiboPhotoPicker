//
//  UIButton+MiOExtension.h
//  微博照片选择
//
//  Created by MiO on 17/2/16.
//  Copyright © 2017年 MiO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (MiOExtension)
/**  扩大buuton点击范围  */
- (void)setEnlargeEdgeWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left;
@end
