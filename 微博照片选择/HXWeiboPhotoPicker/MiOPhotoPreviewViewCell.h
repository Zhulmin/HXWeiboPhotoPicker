//
//  MiOPhotoPreviewViewCell.h
//  微博照片选择
//
//  Created by MiO on 17/2/9.
//  Copyright © 2017年 MiO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MiOPhotoModel.h"
#import <PhotosUI/PhotosUI.h>
@interface MiOPhotoPreviewViewCell : UICollectionViewCell
@property (strong, nonatomic) MiOPhotoModel *model;
@property (strong, nonatomic, readonly) UIImageView *imageView;
@property (strong, nonatomic, readonly) PHLivePhotoView *livePhotoView;
@property (assign, nonatomic) BOOL isAnimating;
@property (assign, nonatomic, readonly) PHImageRequestID requestID;
@property (assign, nonatomic, readonly) PHImageRequestID longRequestId;
@property (assign, nonatomic, readonly) PHImageRequestID liveRequestID; 
- (void)startLivePhoto;
- (void)stopLivePhoto;
- (void)startGifImage;
- (void)stopGifImage;
- (void)fetchLongPhoto;
@end
