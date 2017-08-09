//
//  MiOVideoPresentTransition.h
//  微博照片选择
//
//  Created by MiO on 17/2/22.
//  Copyright © 2017年 MiO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HXVideoPresentTransitionType) {
    HXVideoPresentTransitionPresent = 0,
    HXVideoPresentTransitionDismiss
};

@interface MiOVideoPresentTransition : NSObject<UIViewControllerAnimatedTransitioning>
+ (instancetype)transitionWithTransitionType:(HXVideoPresentTransitionType)type;

- (instancetype)initWithTransitionType:(HXVideoPresentTransitionType)type;
@end
