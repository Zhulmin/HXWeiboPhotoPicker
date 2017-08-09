//
//  MiONaviTransition.h
//  微博照片选择
//
//  Created by MiO on 17/2/9.
//  Copyright © 2017年 MiO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HXTransitionType) {
    HXTransitionTypePush = 0,
    HXTransitionTypePop
};

typedef NS_ENUM(NSUInteger, HXTransitionVcType) {
    HXTransitionVcTypePhoto = 0,
    HXTransitionVcTypeVideo
};

@interface MiOTransition : NSObject<UIViewControllerAnimatedTransitioning>
+ (instancetype)transitionWithType:(HXTransitionType)type VcType:(HXTransitionVcType)vcType;
- (instancetype)initWithTransitionType:(HXTransitionType)type VcType:(HXTransitionVcType)vcType;
@end
