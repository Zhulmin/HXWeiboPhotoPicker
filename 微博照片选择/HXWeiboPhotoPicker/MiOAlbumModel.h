//
//  MiOAlbumModel.h
//  微博照片选择
//
//  Created by MiO on 17/2/8.
//  Copyright © 2017年 MiO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

/**
 *  每个相册的模型
 */

@interface MiOAlbumModel : NSObject

/**
 相册名称
 */
@property (copy, nonatomic) NSString *albumName;

/**
 照片数量
 */
@property (assign, nonatomic) NSInteger count;

/**
 封面Asset
 */
@property (strong, nonatomic) PHAsset *asset;

@property (strong, nonatomic) UIImage *albumImage;

/**
 照片集合对象
 */
@property (strong, nonatomic) PHFetchResult *result;

/**
 标记
 */
@property (assign, nonatomic) NSInteger index;

/**
 选中的个数
 */
@property (assign, nonatomic) NSInteger selectedCount;

@property (assign, nonatomic) CGFloat albumNameWidth;

@end
