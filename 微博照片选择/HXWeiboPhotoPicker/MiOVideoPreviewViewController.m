//
//  MiOVideoPreviewViewController.m
//  微博照片选择
//
//  Created by MiO on 17/2/9.
//  Copyright © 2017年 MiO. All rights reserved.
//

#import "MiOVideoPreviewViewController.h"
#import <AVKit/AVKit.h>
#import <Photos/Photos.h>
#import "MiOTransition.h"
#import "UIView+MiOExtension.h"
#import "UIButton+MiOExtension.h"
#import "MiOPresentTransition.h"
@interface MiOVideoPreviewViewController ()<UIViewControllerTransitioningDelegate>
@property (strong, nonatomic) UIButton *rightBtn;
@property (assign, nonatomic) BOOL firstOn;
@property (assign, nonatomic) BOOL isDelete;
@end

@implementation MiOVideoPreviewViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isDelete = NO;
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.firstOn = YES;
    if (!self.isTouch) {
        [self setup];
    }
}

- (void)setup {
 
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightBtn];
    [self setupNavRightBtn];
    if (!self.isTouch) {
        // 自定义转场动画 添加的一层遮罩
        [self.view addSubview:self.maskView];
    }
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    if (self.isCamera) {
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:self.model.videoURL];
        self.playVideo = [AVPlayer playerWithPlayerItem:playerItem];
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.playVideo];
        playerLayer.frame = CGRectMake(0, 64, width, height - 64);
        if (!self.isTouch) {
            [self.playVideo play];
        }
        [self.view.layer insertSublayer:playerLayer atIndex:0];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pausePlayerAndShowNaviBar) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playVideo.currentItem];
        self.playBtn.frame = CGRectMake(0, 64, width, height - 64);
        [self.view addSubview:self.playBtn];
        if (!self.manager.singleSelected) {
            self.selectedBtn.selected = self.model.selected;
            [self.view addSubview:self.selectedBtn];
        }
    }else {
        __weak typeof(self) weakSelf = self;
        [[PHImageManager defaultManager] requestPlayerItemForVideo:self.model.asset options:nil resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.playVideo = [AVPlayer playerWithPlayerItem:playerItem];
                AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:weakSelf.playVideo];
                playerLayer.frame = CGRectMake(0, 64, width, height - 64);
//                if (!weakSelf.isTouch) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [weakSelf.playVideo play];
                    });
//                }
                [weakSelf.view.layer insertSublayer:playerLayer atIndex:0];
                [[NSNotificationCenter defaultCenter] addObserver:weakSelf selector:@selector(pausePlayerAndShowNaviBar) name:AVPlayerItemDidPlayToEndTimeNotification object:weakSelf.playVideo.currentItem];
                weakSelf.playBtn.frame = CGRectMake(0, 64, width, height - 64);
                [weakSelf.view addSubview:weakSelf.playBtn];
                if (!weakSelf.manager.singleSelected) {
                    weakSelf.selectedBtn.selected = weakSelf.model.selected;
                    [weakSelf.view addSubview:weakSelf.selectedBtn];
                }
            });
        }];
    }
    if (self.selectedComplete) {
        self.rightBtn.hidden = YES;
        self.selectedBtn.hidden = YES;
        UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, width, 64)];
        [self.view addSubview:navBar];
        UINavigationItem *navItem = [[UINavigationItem alloc] init];
        [navBar pushNavigationItem:navItem animated:NO];
        
        navItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle hx_localizedStringForKey:@"取消"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissClick)];
        navBar.tintColor = [UIColor blackColor];
    }
    __weak typeof(self) weakSelf = self;
    [self.manager setPhotoLibraryDidChangeWithVideoViewController:^(NSArray *collectionChanges){
        [weakSelf systemAlbumDidChange:collectionChanges];
    }];
}
- (void)setupNavRightBtn {
    if (self.manager.selectedList.count > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [self.rightBtn setTitle:[NSString stringWithFormat:@"%@(%ld)",[NSBundle hx_localizedStringForKey:@"下一步"],self.manager.selectedList.count] forState:UIControlStateNormal];
        [self.rightBtn setBackgroundColor:[UIColor colorWithRed:253/255.0 green:142/255.0 blue:36/255.0 alpha:1]];
        self.rightBtn.layer.borderWidth = 0;
        CGFloat rightBtnH = self.rightBtn.frame.size.height;
        CGFloat rightBtnW = [MiOPhohoTools getTextWidth:self.rightBtn.currentTitle withHeight:rightBtnH fontSize:14];
        self.rightBtn.frame = CGRectMake(0, 0, rightBtnW + 20, rightBtnH);
    }else {
        [self.rightBtn setTitle:[NSBundle hx_localizedStringForKey:@"下一步"] forState:UIControlStateNormal];
        [self.rightBtn setBackgroundColor:[UIColor colorWithRed:253/255.0 green:142/255.0 blue:36/255.0 alpha:1]];
        self.rightBtn.frame = CGRectMake(0, 0, 60, 25);
        self.rightBtn.layer.borderWidth = 0;
        if (self.model.asset.duration < 3) {
            self.rightBtn.enabled = NO;
            [self.rightBtn setBackgroundColor:[UIColor whiteColor]];
            self.rightBtn.frame = CGRectMake(0, 0, 60, 25);
            self.rightBtn.layer.borderWidth = 0.5;
        }
    }
}
- (void)systemAlbumDidChange:(NSArray *)list {
    if (list.count > 0) {
        NSDictionary *dic = list.firstObject;
        PHFetchResultChangeDetails *collectionChanges = dic[@"collectionChanges"];
        if (collectionChanges) {
            if ([collectionChanges hasIncrementalChanges]) {
                if (collectionChanges.removedObjects.count > 0) {
                    if ([collectionChanges.removedObjects containsObject:self.model.asset]) {
                        self.isDelete = YES;
                        [self setupNavRightBtn];
                        self.selectedBtn.selected = NO;
                    }
                }
            }
        }
    }
}

- (void)dismissClick {
    [self.playVideo pause];
    self.playBtn.selected = NO;
    self.playVideo = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)pausePlayerAndShowNaviBar {
    [self.playVideo pause];
    self.playBtn.selected = NO;
    [self.playVideo.currentItem seekToTime:CMTimeMake(0, 1)];
}

- (void)didPlayBtnClick:(UIButton *)button {
    button.selected = !button.selected;
    
    if (button.selected) {
        [self.playVideo play];
    }else {
        [self.playVideo pause];
    }
}

- (UIButton *)playBtn
{
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setImage:[MiOPhohoTools hx_imageNamed:@"multimedia_videocard_play@2x.png"] forState:UIControlStateNormal];
        [_playBtn setImage:[[UIImage alloc] init] forState:UIControlStateSelected];
        [_playBtn addTarget:self action:@selector(didPlayBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _playBtn.selected = YES;
    }
    return _playBtn;
}

- (UIButton *)selectedBtn {
    if (!_selectedBtn) {
        CGFloat width = self.view.frame.size.width;
        _selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectedBtn setImage:[MiOPhohoTools hx_imageNamed:@"compose_guide_check_box_default@2x.png"] forState:UIControlStateNormal];
        [_selectedBtn setImage:[MiOPhohoTools hx_imageNamed:@"compose_guide_check_box_right@2x.png"] forState:UIControlStateSelected];
        CGFloat selectedBtnW = _selectedBtn.currentImage.size.width;
        CGFloat selectedBtnH = _selectedBtn.currentImage.size.height;
        _selectedBtn.frame = CGRectMake(width - 30 - selectedBtnW, 84, selectedBtnW, selectedBtnH);
        [_selectedBtn addTarget:self action:@selector(didSelectedClick:) forControlEvents:UIControlEventTouchUpInside];
        [_selectedBtn setEnlargeEdgeWithTop:20 right:20 bottom:20 left:20];
    }
    return _selectedBtn;
}

- (void)selectClick {
    if (!self.selectedBtn.selected) {
        [self didSelectedClick:self.selectedBtn];
    }
}

- (void)didSelectedClick:(UIButton *)button {
    if (self.isDelete) {
        [self.view showImageHUDText:@"视频已被删除!"];
        return;
    }
    MiOPhotoModel *model = self.model;
    if (!button.selected) {
        NSString *str = [MiOPhohoTools maximumOfJudgment:model manager:self.manager];
        if (str) {
            if (!self.isTouch) {
                [self.view showImageHUDText:str];
            }else {
                if (self.firstOn) {
                    self.firstOn = NO;
                }else {
                    [self.view showImageHUDText:str];
                }
            }
            return;
        }
        if (model.type != HXPhotoModelMediaTypeCameraVideo && model.type != HXPhotoModelMediaTypeCameraPhoto) {
            model.thumbPhoto = self.coverImage;
            model.previewPhoto = self.coverImage;
        }
        if (model.type == HXPhotoModelMediaTypePhoto || model.type == HXPhotoModelMediaTypePhotoGif) {
            [self.manager.selectedPhotos addObject:model];
        }else if (model.type == HXPhotoModelMediaTypeVideo) {
            [self.manager.selectedVideos addObject:model];
        }else if (model.type == HXPhotoModelMediaTypeCameraPhoto) {
            [self.manager.selectedPhotos addObject:model];
            [self.manager.selectedCameraPhotos addObject:model];
            [self.manager.selectedCameraList addObject:model];
        }else if (model.type == HXPhotoModelMediaTypeCameraVideo) {
            [self.manager.selectedVideos addObject:model];
            [self.manager.selectedCameraVideos addObject:model];
            [self.manager.selectedCameraList addObject:model];
        }
        [self.manager.selectedList addObject:model];
        CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        anim.duration = 0.25;
        anim.values = @[@(1.2),@(0.8),@(1.1),@(0.9),@(1.0)];
        [button.layer addAnimation:anim forKey:@""];
    }else {
        if (model.type != HXPhotoModelMediaTypeCameraVideo && model.type != HXPhotoModelMediaTypeCameraPhoto) {
            model.thumbPhoto = nil;
            model.previewPhoto = nil;
        }
        if ((model.type == HXPhotoModelMediaTypePhoto || model.type == HXPhotoModelMediaTypePhotoGif) || (model.type == HXPhotoModelMediaTypeVideo || model.type == HXPhotoModelMediaTypeLivePhoto)) {
            if (model.type == HXPhotoModelMediaTypePhoto || model.type == HXPhotoModelMediaTypePhotoGif || model.type == HXPhotoModelMediaTypeLivePhoto) {
                [self.manager.selectedPhotos removeObject:model];
            }else if (model.type == HXPhotoModelMediaTypeVideo) {
                [self.manager.selectedVideos removeObject:model];
            }
        }else if (model.type == HXPhotoModelMediaTypeCameraPhoto || model.type == HXPhotoModelMediaTypeCameraVideo) {
            if (model.type == HXPhotoModelMediaTypeCameraPhoto) {
                [self.manager.selectedPhotos removeObject:model];
                [self.manager.selectedCameraPhotos removeObject:model];
            }else if (model.type == HXPhotoModelMediaTypeCameraVideo) {
                [self.manager.selectedVideos removeObject:model];
                [self.manager.selectedCameraVideos removeObject:model];
            }
            [self.manager.selectedCameraList removeObject:model];
        }
        [self.manager.selectedList removeObject:model];
    }
    button.selected = !button.selected;
    model.selected = button.selected;
    if (self.manager.selectedList.count > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [self.rightBtn setTitle:[NSString stringWithFormat:@"%@(%ld)",[NSBundle hx_localizedStringForKey:@"下一步"],self.manager.selectedList.count] forState:UIControlStateNormal];
        [self.rightBtn setBackgroundColor:[UIColor colorWithRed:253/255.0 green:142/255.0 blue:36/255.0 alpha:1]];
        self.rightBtn.layer.borderWidth = 0;
        CGFloat rightBtnH = self.rightBtn.frame.size.height;
        CGFloat rightBtnW = [MiOPhohoTools getTextWidth:self.rightBtn.currentTitle withHeight:rightBtnH fontSize:14];
        self.rightBtn.frame = CGRectMake(0, 0, rightBtnW + 20, rightBtnH);
    }else {
        [self.rightBtn setTitle:[NSBundle hx_localizedStringForKey:@"下一步"] forState:UIControlStateNormal];
        [self.rightBtn setBackgroundColor:[UIColor colorWithRed:253/255.0 green:142/255.0 blue:36/255.0 alpha:1]];
        self.rightBtn.frame = CGRectMake(0, 0, 60, 25);
        self.rightBtn.layer.borderWidth = 0;
    }
    
    if ([self.delegate respondsToSelector:@selector(previewVideoDidSelectedClick:)]) {
        [self.delegate previewVideoDidSelectedClick:model];
    }
}

- (UIButton *)rightBtn {
    if (!_rightBtn) {
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightBtn setTitle:[NSBundle hx_localizedStringForKey:@"下一步"] forState:UIControlStateNormal];
        [_rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_rightBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [_rightBtn setTitleColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        _rightBtn.layer.masksToBounds = YES;
        _rightBtn.layer.cornerRadius = 2;
        _rightBtn.layer.borderWidth = 0.5;
        _rightBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [_rightBtn setBackgroundColor:[UIColor whiteColor]];
        [_rightBtn addTarget:self action:@selector(didNextClick:) forControlEvents:UIControlEventTouchUpInside];
        _rightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _rightBtn.frame = CGRectMake(0, 0, 60, 25);
    }
    return _rightBtn;
}

- (void)didNextClick:(UIButton *)button {
    [self.playVideo pause];
    self.playVideo = nil;
    BOOL max = NO;
    if (self.manager.selectedList.count == self.manager.maxNum) {
        // 已经达到最大选择数
        max = YES;
    }
    if (self.manager.type == MiOPhotoManagerSelectedTypePhotoAndVideo) {
        if (self.model.type == HXPhotoModelMediaTypeVideo || self.model.type == HXPhotoModelMediaTypeCameraVideo) {
            if (self.manager.photoMaxNum > 0) {
                if (!self.manager.selectTogether) { // 是否支持图片视频同时选择
                    if (self.manager.selectedPhotos.count > 0 ) {
                        // 已经选择了图片,不能再选视频
                        max = YES;
                    }
                }
            }
            if (self.manager.selectedVideos.count == self.manager.videoMaxNum) {
                // 已经达到视频最大选择数
                max = YES;
            }
        }
    }else if (self.manager.type == MiOPhotoManagerSelectedTypeVideo) {
        if (self.manager.selectedVideos.count == self.manager.videoMaxNum) {
            // 已经达到视频最大选择数
            max = YES;
        }
    }
    if (self.model.type == HXPhotoModelMediaTypeVideo) {
        if (self.model.asset.duration < 3) {
            max = YES;
        }
    }
    if (!self.isPreview) {
        if (self.manager.selectedList.count == 0) {
            if (!self.selectedBtn.selected && !max && !self.isDelete) {
                self.model.thumbPhoto = self.coverImage;
                self.model.previewPhoto = self.coverImage;
                self.model.selected = YES;
                [self.manager.selectedList addObject:self.model];
                [self.manager.selectedVideos addObject:self.model];
            }
        }
    }
    if ([self.delegate respondsToSelector:@selector(previewVideoDidNextClick)]) {
        [self.delegate previewVideoDidNextClick];
    }
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:self.view.bounds];
        _maskView.backgroundColor = [UIColor whiteColor];
    }
    return _maskView;
}

- (void)dealloc {
    [self.playVideo pause];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.playVideo = nil;
    NSSLog(@"dealloc");
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
    if (operation == UINavigationControllerOperationPush) {
        return [MiOTransition transitionWithType:HXTransitionTypePush VcType:HXTransitionVcTypeVideo];
    }else {
        return [MiOTransition transitionWithType:HXTransitionTypePop VcType:HXTransitionVcTypeVideo];
    }
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return [MiOPresentTransition transitionWithTransitionType:HXPresentTransitionTypePresent VcType:HXPresentTransitionVcTypeVideo withPhotoView:self.photoView];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return [MiOPresentTransition transitionWithTransitionType:HXPresentTransitionTypeDismiss VcType:HXPresentTransitionVcTypeVideo withPhotoView:self.photoView];
}


@end
