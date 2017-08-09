//
//  MiOAlbumTitleButton.m
//  微博照片选择
//
//  Created by MiO on 17/2/9.
//  Copyright © 2017年 MiO. All rights reserved.
//

#import "MiOAlbumTitleButton.h"

@implementation MiOAlbumTitleButton

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat titleY = self.titleLabel.frame.origin.y;
    CGFloat titleH = self.titleLabel.frame.size.height;
    CGFloat titleW = self.titleLabel.frame.size.width;

    CGFloat imageY = self.imageView.frame.origin.y;
    CGFloat imageW = self.imageView.frame.size.width;
    CGFloat imageH = self.imageView.frame.size.height;
    
    CGFloat width = self.frame.size.width;
    
    self.titleLabel.frame = CGRectMake((width - (titleW + imageW + 5)) / 2, titleY, titleW, titleH);
    
    self.imageView.frame = CGRectMake(CGRectGetMaxX(self.titleLabel.frame) + 5, imageY, imageW, imageH);
}

@end
