//
//  MiOPhotoViewCell.m
//  微博照片选择
//
//  Created by MiO on 17/2/8.
//  Copyright © 2017年 MiO. All rights reserved.
//

#import "MiOPhotoViewCell.h"
#import "MiOPhohoTools.h"
#import "UIButton+MiOExtension.h"
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import "MiOPhotoPreviewViewController.h"
@interface MiOPhotoViewCell ()<UIViewControllerPreviewingDelegate>
@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) UIButton *cameraBtn;
@property (strong, nonatomic) UIImageView *videoIcon;
@property (strong, nonatomic) UILabel *videoTime;
@property (strong, nonatomic) UIImageView *gifIcon;
@property (strong, nonatomic) UIImageView *liveIcon;
@property (strong, nonatomic) UIButton *liveBtn;
@property (strong, nonatomic) PHLivePhotoView *livePhotoView;
@property (copy, nonatomic) NSString *localIdentifier;
@property (strong, nonatomic) UIImageView *previewImg;
@property (assign, nonatomic) PHImageRequestID liveRequestID;
@property (assign, nonatomic) BOOL addImageComplete;

@end

@implementation MiOPhotoViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.requestID = 0; 
        [self setup];
    }
    return self;
}
#pragma mark - < 懒加载 >
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.frame = self.bounds;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}
- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.hx_h - 25, self.hx_w, 25)];
        _bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        _bottomView.hidden = YES;
    }
    return _bottomView;
}
- (UIImageView *)videoIcon {
    if (!_videoIcon) {
        _videoIcon = [[UIImageView alloc] init];
//        _videoIcon = [[UIImageView alloc] initWithImage:[HXPhotoTools hx_imageNamed:@"VideoSendIcon@2x.png"]];
        _videoIcon.frame = CGRectMake(5, 0, 17, 17);
        _videoIcon.center = CGPointMake(_videoIcon.center.x, 25 / 2);
    }
    return _videoIcon;
}
- (UILabel *)videoTime {
    if (!_videoTime) {
        _videoTime = [[UILabel alloc] init];
        _videoTime.textColor = [UIColor whiteColor];
        _videoTime.textAlignment = NSTextAlignmentRight;
        _videoTime.font = [UIFont systemFontOfSize:10];
        _videoTime.frame = CGRectMake(CGRectGetMaxX(_videoTime.frame), 0, self.hx_w - CGRectGetMaxX(_videoTime.frame) - 5, 25);
    }
    return _videoTime;
}
- (UIImageView *)gifIcon {
    if (!_gifIcon) {
        _gifIcon = [[UIImageView alloc] init];
//        _gifIcon = [[UIImageView alloc] initWithImage:[HXPhotoTools hx_imageNamed:@"timeline_image_gif@2x.png"]];
        _gifIcon.frame = CGRectMake(self.hx_w - 28, self.hx_h - 18, 28, 18);
    }
    return _gifIcon;
}
- (UIImageView *)liveIcon {
    if (!_liveIcon) {
        _liveIcon = [[UIImageView alloc] init];
//        _liveIcon = [[UIImageView alloc] initWithImage:[HXPhotoTools hx_imageNamed:@"compose_live_photo_open_only_icon@2x.png"]];
        _liveIcon.frame = CGRectMake(7, 5, 18, 18);
    }
    return _liveIcon;
}
- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:self.bounds];
        _maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        _maskView.hidden = YES;
    }
    return _maskView;
}
- (UIButton *)liveBtn {
    if (!_liveBtn) {
        _liveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_liveBtn setImage:[HXPhotoTools hx_imageNamed:@"compose_live_photo_open_icon@2x.png"] forState:UIControlStateNormal];
        [_liveBtn setTitle:@"LIVE" forState:UIControlStateNormal];
//        [_liveBtn setImage:[HXPhotoTools hx_imageNamed:@"compose_live_photo_close_icon@2x.png"] forState:UIControlStateSelected];
        [_liveBtn setTitle:[NSBundle hx_localizedStringForKey:@"关闭"] forState:UIControlStateSelected];
//        [_liveBtn setBackgroundImage:[HXPhotoTools hx_imageNamed:@"compose_live_photo_background@2x.png"] forState:UIControlStateNormal];
        [_liveBtn setTitleColor:[UIColor colorWithRed:85/255.0 green:85/255.0 blue:85/255.0 alpha:1] forState:UIControlStateNormal];
        _liveBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
        _liveBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 2, 0, 0);
        _liveBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        _liveBtn.frame = CGRectMake(5, 5, 55, 24);
        [_liveBtn addTarget:self action:@selector(didLivePhotoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _liveBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _liveBtn.hidden = YES;
    }
    return _liveBtn;
}
- (UIButton *)selectBtn {
    if (!_selectBtn) {
        _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_selectBtn setImage:[HXPhotoTools hx_imageNamed:@"compose_guide_check_box_default@2x.png"] forState:UIControlStateNormal];
//        [_selectBtn setImage:[HXPhotoTools hx_imageNamed:@"compose_guide_check_box_right@2x.png"] forState:UIControlStateSelected];
        [_selectBtn addTarget:self action:@selector(didSelectClick:) forControlEvents:UIControlEventTouchUpInside];
        _selectBtn.frame = CGRectMake(self.hx_w - 32, 0, 32, 32);
        _selectBtn.center = CGPointMake(_selectBtn.center.x, self.liveBtn.center.y);
        self.liveIcon.center = CGPointMake(self.liveIcon.center.x, self.liveBtn.center.y);
        [_selectBtn setEnlargeEdgeWithTop:0 right:0 bottom:30 left:30];
    }
    return _selectBtn;
}
- (UIButton *)cameraBtn {
    if (!_cameraBtn) {
        _cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cameraBtn setBackgroundColor:[UIColor whiteColor]];
        _cameraBtn.userInteractionEnabled = NO;
        _cameraBtn.frame = self.bounds;
    }
    return _cameraBtn;
}
- (void)setIconDic:(NSDictionary *)iconDic {
    _iconDic = iconDic;
    if (self.addImageComplete) {
        return;
    }
    if (!self.videoIcon.image) {
        self.videoIcon.image = iconDic[@"videoIcon"];
    }
    if (!self.gifIcon.image) {
        self.gifIcon.image = iconDic[@"gifIcon"];
    }
    if (!self.liveIcon.image) {
        self.liveIcon.image = iconDic[@"liveIcon"];
    }
    if (!self.liveBtn.currentImage) {
        [self.liveBtn setImage:iconDic[@"liveBtnImageNormal"] forState:UIControlStateNormal];
        [self.liveBtn setImage:iconDic[@"liveBtnImageSelected"] forState:UIControlStateSelected];
    }
    if (!self.liveBtn.currentBackgroundImage) {
        [self.liveBtn setBackgroundImage:iconDic[@"liveBtnBackgroundImage"] forState:UIControlStateNormal];
    }
    if (!self.selectBtn.currentImage) {
        [self.selectBtn setImage:iconDic[@"selectBtnNormal"] forState:UIControlStateNormal];
        [self.selectBtn setImage:iconDic[@"selectBtnSelected"] forState:UIControlStateSelected];
    }
    self.addImageComplete = YES;
}
- (void)setup {
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.bottomView];
    [self.bottomView addSubview:self.videoIcon];
    [self.bottomView addSubview:self.videoTime];
    [self.contentView addSubview:self.gifIcon];
    [self.contentView addSubview:self.liveIcon];
    [self.contentView addSubview:self.maskView];
    [self.contentView addSubview:self.liveBtn];
    [self.contentView addSubview:self.selectBtn];
    [self.contentView addSubview:self.cameraBtn];
}

- (void)didLivePhotoBtnClick:(UIButton *)button {
    button.selected = !button.selected;
    self.model.isCloseLivePhoto = button.selected;
    if (button.selected) {
        [self.livePhotoView stopPlayback];
        [self.livePhotoView removeFromSuperview];
    }else {
        [self startLivePhoto];
    }
    if ([self.delegate respondsToSelector:@selector(cellChangeLivePhotoState:)]) {
        [self.delegate cellChangeLivePhotoState:self.model];
    }
}

- (PHLivePhotoView *)livePhotoView {
    if (!_livePhotoView) {
        _livePhotoView = [[PHLivePhotoView alloc] init];
        _livePhotoView.clipsToBounds = YES;
        _livePhotoView.contentMode = UIViewContentModeScaleAspectFill;
        _livePhotoView.frame = self.bounds;
    }
    return _livePhotoView;
}

- (void)startLivePhoto {
    self.liveIcon.hidden = YES;
    self.liveBtn.hidden = NO;
    if (self.model.isCloseLivePhoto) {
        return;
    }
    [self.contentView insertSubview:self.livePhotoView aboveSubview:self.imageView];
//    if (self.model.livePhoto) {
//        self.livePhotoView.livePhoto = self.model.livePhoto;
//        [self.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleHint];
//    }else {
        CGFloat width = self.frame.size.width;
        __weak typeof(self) weakSelf = self;
        CGSize size;
        if (self.model.imageSize.width > self.model.imageSize.height / 9 * 15) {
            size = CGSizeMake(width, width * 1.5);
        }else if (self.model.imageSize.height > self.model.imageSize.width / 9 * 15) {
            size = CGSizeMake(width * 1.5, width);
        }else {
            size = CGSizeMake(width, width);
        }
        self.liveRequestID = [MiOPhohoTools FetchLivePhotoForPHAsset:self.model.asset Size:size Completion:^(PHLivePhoto *livePhoto, NSDictionary *info) {
//            weakSelf.model.livePhoto = livePhoto;
            weakSelf.livePhotoView.livePhoto = livePhoto;
            [weakSelf.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleHint];
        }];
//    }
}

- (void)stopLivePhoto {
    [[PHCachingImageManager defaultManager] cancelImageRequest:self.liveRequestID];
    self.liveIcon.hidden = NO;
    self.liveBtn.hidden = YES;
    [self.livePhotoView stopPlayback];
    [self.livePhotoView removeFromSuperview];  
    self.model.livePhoto = nil;
}

- (void)didSelectClick:(UIButton *)button {
    if (self.model.type == HXPhotoModelMediaTypeCamera) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(cellDidSelectedBtnClick:Model:)]) {
        [self.delegate cellDidSelectedBtnClick:self Model:self.model];
    }
}

- (void)setSingleSelected:(BOOL)singleSelected {
    _singleSelected = singleSelected;
    if (singleSelected) {
        self.maskView.hidden = YES;
        self.selectBtn.hidden = YES;
    }
}

- (void)setModel:(MiOPhotoModel *)model {
    _model = model; 
    if (model.thumbPhoto) {
        self.imageView.image = model.thumbPhoto;
    }else {
        if (model.requestID) {
            [[PHImageManager defaultManager] cancelImageRequest:model.requestID];
            model.requestID = 0;
        }
        self.localIdentifier = model.asset.localIdentifier;
        __weak typeof(self) weakSelf = self;
        int32_t requestID = [MiOPhohoTools fetchPhotoWithAsset:model.asset photoSize:model.requestSize completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
//            __strong typeof(weakSelf) strongSelf = weakSelf;
            if ([weakSelf.localIdentifier isEqualToString:model.asset.localIdentifier]) {
                weakSelf.imageView.image = photo;
            } else {
                [[PHImageManager defaultManager] cancelImageRequest:weakSelf.requestID];
            }
            if (!isDegraded) {
                weakSelf.requestID = 0;
            }
        }];
        if (requestID && self.requestID && requestID != self.requestID) {
            [[PHImageManager defaultManager] cancelImageRequest:self.requestID];
        }
        self.requestID = requestID;
    }

    self.videoTime.text = model.videoTime;
    self.liveIcon.hidden = YES;
    self.liveBtn.hidden = YES;
    self.gifIcon.hidden = YES;
    self.cameraBtn.hidden = YES;
    if (model.type == HXPhotoModelMediaTypeVideo) {
        self.bottomView.hidden = NO;
    }else if (model.type == HXPhotoModelMediaTypePhoto || (model.type == HXPhotoModelMediaTypePhotoGif || model.type == HXPhotoModelMediaTypeLivePhoto)){
        self.bottomView.hidden = YES;
        if (model.type == HXPhotoModelMediaTypePhotoGif) {
            self.gifIcon.hidden = NO;
        }else if (model.type == HXPhotoModelMediaTypeLivePhoto) {
            self.liveIcon.hidden = NO;
            if (model.selected) {
                self.liveIcon.hidden = YES;
                self.liveBtn.hidden = NO;
                self.liveBtn.selected = model.isCloseLivePhoto;
            }
        }
    }else if (model.type == HXPhotoModelMediaTypeCamera){
        [self.cameraBtn setImage:model.thumbPhoto forState:UIControlStateNormal];
        self.cameraBtn.hidden = NO;
    }else if (model.type == HXPhotoModelMediaTypeCameraPhoto) {
        self.bottomView.hidden = YES;
    }else if (model.type == HXPhotoModelMediaTypeCameraVideo) {
        self.bottomView.hidden = NO;
    }
    self.maskView.hidden = !model.selected;
    self.selectBtn.selected = model.selected;
}
- (void)dealloc {
    if (self.requestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.requestID];
        self.requestID = 0;
    }
    if (self.model.requestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.model.requestID];
        self.model.requestID = 0;
    }
}

@end
