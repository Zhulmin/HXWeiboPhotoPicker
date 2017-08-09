//
//  MiOPhotoViewCell.h
//  微博照片选择
//
//  Created by MiO on 17/2/8.
//  Copyright © 2017年 MiO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MiOPhotoModel.h"

@class MiOPhotoViewCell;
@protocol HXPhotoViewCellDelegate <NSObject>

//- (void)didCameraClick;
- (void)cellDidSelectedBtnClick:(MiOPhotoViewCell *)cell Model:(MiOPhotoModel *)model;
- (void)cellChangeLivePhotoState:(MiOPhotoModel *)model;
@end

@interface MiOPhotoViewCell : UICollectionViewCell
@property (weak, nonatomic) id<HXPhotoViewCellDelegate> delegate;
@property (weak, nonatomic) id<UIViewControllerPreviewing> previewingContext;
@property (assign, nonatomic) BOOL firstRegisterPreview;
@property (assign, nonatomic) BOOL singleSelected;
@property (strong, nonatomic) MiOPhotoModel *model;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIView *maskView;
@property (strong, nonatomic) UIButton *selectBtn;
@property (assign, nonatomic) int32_t requestID;
@property (copy, nonatomic) NSDictionary *iconDic;

- (void)startLivePhoto;
- (void)stopLivePhoto;
@end
