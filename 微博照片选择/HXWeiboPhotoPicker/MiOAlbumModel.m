//
//  MiOAlbumModel.m
//  微博照片选择
//
//  Created by MiO on 17/2/8.
//  Copyright © 2017年 MiO. All rights reserved.
//

#import "MiOAlbumModel.h"
#import "MiOPhohoTools.h"
@implementation MiOAlbumModel
- (CGFloat)albumNameWidth {
    if (_albumNameWidth == 0) {
        _albumNameWidth = [MiOPhohoTools getTextWidth:self.albumName withHeight:18 fontSize:17];
    }
    return _albumNameWidth;
}
@end
