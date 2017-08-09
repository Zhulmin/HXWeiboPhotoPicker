//
//  MiOFullScreenCameraViewController.h
//  微博照片选择
//
//  Created by MiO on 2017/5/22.
//  Copyright © 2017年 MiO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MiOCameraViewController.h"

@protocol HXFullScreenCameraViewControllerDelegate <NSObject>

- (void)fullScreenCameraDidNextClick:(MiOPhotoModel *)model;

@end
@interface MiOFullScreenCameraViewController : UIViewController

@property (weak, nonatomic) id<HXFullScreenCameraViewControllerDelegate> delegate;
@property (assign, nonatomic) BOOL isVideo;
@property (assign, nonatomic) HXCameraType type;
@property (strong, nonatomic) MiOPhotoManager *photoManager;
@end
