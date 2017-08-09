//
//  MiOPhotoEditViewController.h
//  微博照片选择
//
//  Created by MiO on 2017/6/30.
//  Copyright © 2017年 MiO. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MiOPhotoModel,MiOPhotoManager;
@protocol HXPhotoEditViewControllerDelegate <NSObject>

- (void)editViewControllerDidNextClick:(MiOPhotoModel *)model;

@end

@class MiOPhotoModel;
@interface MiOPhotoEditViewController : UIViewController
@property (strong, nonatomic) MiOPhotoModel *model;
@property (strong, nonatomic) UIImage *coverImage;
@property (weak, nonatomic) id<HXPhotoEditViewControllerDelegate> delegate;
@property (strong, nonatomic) MiOPhotoManager *photoManager;
@end
