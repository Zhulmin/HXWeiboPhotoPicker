//
//  MiOVideoPreviewViewController.h
//  微博照片选择
//
//  Created by MiO on 17/2/9.
//  Copyright © 2017年 MiO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MiOPhotoModel.h"
#import "MiOPhotoManager.h"

@protocol HXVideoPreviewViewControllerDelegate <NSObject>

- (void)previewVideoDidSelectedClick:(MiOPhotoModel *)model;
- (void)previewVideoDidNextClick;

@end

@class MiOPhotoView;
@interface MiOVideoPreviewViewController : UIViewController<UINavigationControllerDelegate>
@property (assign, nonatomic) BOOL isTouch;
@property (weak, nonatomic) id<HXVideoPreviewViewControllerDelegate> delegate;
@property (strong, nonatomic) MiOPhotoModel *model;
@property (strong, nonatomic) MiOPhotoManager *manager;
@property (strong, nonatomic) UIView *maskView;
@property (strong, nonatomic) AVPlayer *playVideo;
@property (strong, nonatomic) UIButton *playBtn;
@property (assign, nonatomic) BOOL isCamera;
@property (assign, nonatomic) BOOL selectedComplete;
@property (assign, nonatomic) BOOL isPreview; // 是否预览
@property (strong, nonatomic) UIImage *coverImage;
@property (strong, nonatomic) UIButton *selectedBtn;

@property (strong, nonatomic) MiOPhotoView *photoView;
- (void)setup;
- (void)selectClick;
@end
