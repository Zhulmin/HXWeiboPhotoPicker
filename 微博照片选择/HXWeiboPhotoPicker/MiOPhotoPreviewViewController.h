//
//  MiOPhotoPreviewViewController.h
//  微博照片选择
//
//  Created by MiO on 17/2/9.
//  Copyright © 2017年 MiO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MiOPhotoManager.h"

@protocol HXPhotoPreviewViewControllerDelegate <NSObject>

- (void)didSelectedClick:(MiOPhotoModel *)model AddOrDelete:(BOOL)state;
- (void)previewDidNextClick;

@end

@class MiOPhotoView;
@interface MiOPhotoPreviewViewController : UIViewController<UINavigationControllerDelegate>
@property (weak, nonatomic) id<HXPhotoPreviewViewControllerDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *modelList;
@property (assign, nonatomic) NSInteger index;
@property (strong, nonatomic) MiOPhotoManager *manager;
@property (weak, nonatomic, readonly) UICollectionView *collectionView;
@property (assign, nonatomic) BOOL selectedComplete;
@property (assign, nonatomic) BOOL isPreview; // 是否预览
@property (strong, nonatomic) MiOPhotoView *photoView;
@property (assign, nonatomic) BOOL isTouch;// 是否为3dThouch预览
@property (strong, nonatomic) UIButton *selectedBtn;
@property (strong, nonatomic) UIImage *gifCoverImage;
- (void)setup;
- (void)selectClick;
@end
