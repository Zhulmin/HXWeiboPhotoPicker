//
//  MiOPhotoSubViewCell.h
//  微博照片选择
//
//  Created by MiO on 17/2/17.
//  Copyright © 2017年 MiO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@protocol HXPhotoSubViewCellDelegate <NSObject>

- (void)cellDidDeleteClcik:(UICollectionViewCell *)cell;
- (void)cellNetworkingPhotoDownLoadComplete;
@end

@class MiOPhotoModel;
@interface MiOPhotoSubViewCell : UICollectionViewCell
@property (weak, nonatomic) id<HXPhotoSubViewCellDelegate> delegate;
@property (strong, nonatomic, readonly) UIImageView *imageView;
@property (strong, nonatomic) MiOPhotoModel *model;
/**
 删除网络图片时是否显示Alert // 默认显示
 */
@property (assign, nonatomic) BOOL showDeleteNetworkPhotoAlert;
// 重新下载
- (void)againDownload;
@end
