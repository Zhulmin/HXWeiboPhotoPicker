//
//  MiOPresentTransition.h
//  微博照片选择
//
//  Created by MiO on 17/2/21.
//  Copyright © 2017年 MiO. All rights reserved.
//

#import <UIKit/UIKit.h> 
#import "MiOPhotoView.h"
typedef NS_ENUM(NSUInteger, HXPresentTransitionType) {
    HXPresentTransitionTypePresent = 0,
    HXPresentTransitionTypeDismiss
};

typedef NS_ENUM(NSUInteger, HXPresentTransitionVcType) {
    HXPresentTransitionVcTypePhoto = 0,
    HXPresentTransitionVcTypeVideo
};

@interface MiOPresentTransition : NSObject<UIViewControllerAnimatedTransitioning>

+ (instancetype)transitionWithTransitionType:(HXPresentTransitionType)type VcType:(HXPresentTransitionVcType)vcType withPhotoView:(MiOPhotoView *)photoView;

- (instancetype)initWithTransitionType:(HXPresentTransitionType)type VcType:(HXPresentTransitionVcType)vcType withPhotoView:(MiOPhotoView *)photoView;

@end
