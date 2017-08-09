//
//  MiOPhotoView.h
//  微博照片选择
//
//  Created by MiO on 17/2/17.
//  Copyright © 2017年 MiO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MiOPhotoManager.h"

/*
 *  使用选择照片之后自动布局的功能时就创建此块View. 初始化方法传入照片管理类
 */
@class MiOPhotoView;
@protocol HXPhotoViewDelegate <NSObject>
@optional
// 代理返回 选择、移动顺序、删除之后的图片以及视频
- (void)photoView:(MiOPhotoView *)photoView changeComplete:(NSArray<MiOPhotoModel *> *)allList photos:(NSArray<MiOPhotoModel *> *)photos videos:(NSArray<MiOPhotoModel *> *)videos original:(BOOL)isOriginal;

// 这次在相册选择的图片,不是所有选择的所有图片.
//- (void)photoViewCurrentSelected:(NSArray<HXPhotoModel *> *)allList photos:(NSArray<HXPhotoModel *> *)photos videos:(NSArray<HXPhotoModel *> *)videos original:(BOOL)isOriginal;

// 当view更新高度时调用
- (void)photoView:(MiOPhotoView *)photoView updateFrame:(CGRect)frame;

// 删除网络图片的地址
- (void)photoView:(MiOPhotoView *)photoView deleteNetworkPhoto:(NSString *)networkPhotoUrl;

/**  网络图片全部下载完成时调用  */
- (void)photoViewAllNetworkingPhotoDownloadComplete:(MiOPhotoView *)photoView;

@end

@class MiOCollectionView;
@interface MiOPhotoView : UIView
@property (weak, nonatomic) id<HXPhotoViewDelegate> delegate;
@property (strong, nonatomic) MiOPhotoManager *manager;
@property (strong, nonatomic) NSIndexPath *currentIndexPath; // 自定义转场动画时用到的属性
@property (weak, nonatomic) MiOCollectionView *collectionView;
- (instancetype)initWithFrame:(CGRect)frame WithManager:(MiOPhotoManager *)manager;
- (instancetype)initWithManager:(MiOPhotoManager *)manager;
+ (instancetype)photoManager:(MiOPhotoManager *)manager;
- (void)goPhotoViewController;
/**  网络图片是否全部下载完成  */
- (BOOL)networkingPhotoDownloadComplete;
/**  已下载完成的网络图片数量  */
- (NSInteger)downloadNumberForNetworkingPhoto;
/**  刷新view  */
- (void)refreshView;
@end
