//
//  UIImage+MiOExtension.h
//  微博照片选择
//
//  Created by MiO on 17/2/15.
//  Copyright © 2017年 MiO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (MiOExtension)
+ (UIImage *)animatedGIFWithData:(NSData *)data;
- (UIImage *)animatedImageByScalingAndCroppingToSize:(CGSize)size;
- (UIImage *)normalizedImage;
- (UIImage *)clipImage:(CGFloat)scale;
- (UIImage *)scaleImagetoScale:(float)scaleSize;
- (UIImage *)clipNormalizedImage:(CGFloat)scale;
- (UIImage *)fullNormalizedImage;
- (UIImage *)clipLeftOrRightImage:(CGFloat)scale;
@end
