//
//  MiOCameraViewController.h
//  微博照片选择
//
//  Created by MiO on 17/2/13.
//  Copyright © 2017年 MiO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MiOPhotoModel.h"

typedef enum : NSUInteger {
    HXCameraTypePhoto = 0,
    HXCameraTypeVideo,
    HXCameraTypePhotoAndVideo
} HXCameraType;

@protocol HXCameraViewControllerDelegate <NSObject>

- (void)cameraDidNextClick:(MiOPhotoModel *)model;

@end

@class MiOPhotoManager;
@interface MiOCameraViewController : UIViewController
@property (weak, nonatomic) id<HXCameraViewControllerDelegate> delegate;
@property (assign, nonatomic) BOOL isVideo;
@property (strong, nonatomic) MiOPhotoManager *photoManager;
@property (assign, nonatomic) HXCameraType type;
@end
