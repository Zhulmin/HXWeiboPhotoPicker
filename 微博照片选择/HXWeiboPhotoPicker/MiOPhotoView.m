//
//  MiOPhotoView.m
//  微博照片选择
//
//  Created by MiO on 17/2/17.
//  Copyright © 2017年 MiO. All rights reserved.
//

#import "MiOPhotoView.h"
#import "MiOCollectionView.h"
#import "MiOPhotoSubViewCell.h"
#import "MiOPhotoViewController.h"
#import "MiOPhotoPreviewViewController.h"
#import "MiOVideoPreviewViewController.h"
#import "MiOCameraViewController.h"
#import "UIView+MiOExtension.h"
#import "MiOFullScreenCameraViewController.h"


#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.1f)
#define Spacing 3 // 每个item的间距
#define LineNum 3 // 每行个数
@interface MiOPhotoView ()<HXCollectionViewDataSource,HXCollectionViewDelegate,HXPhotoViewControllerDelegate,HXPhotoSubViewCellDelegate,UIActionSheetDelegate,HXCameraViewControllerDelegate,UIAlertViewDelegate,HXFullScreenCameraViewControllerDelegate>
@property (strong, nonatomic) NSMutableArray *dataList;
@property (strong, nonatomic) NSMutableArray *photos;
@property (strong, nonatomic) NSMutableArray *videos;
@property (strong, nonatomic) MiOPhotoModel *addModel;
@property (assign, nonatomic) BOOL isAddModel;
@property (assign, nonatomic) BOOL original;
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (assign, nonatomic) NSInteger numOfLinesOld;
@property (strong, nonatomic) NSMutableArray *networkPhotos;
@property (assign, nonatomic) BOOL downLoadComplete;
@property (strong, nonatomic) UIImage *tempCameraImage;
@end

@implementation MiOPhotoView
- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
    }
    return _flowLayout;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (MiOPhotoModel *)addModel {
    if (!_addModel) {
        _addModel = [[MiOPhotoModel alloc] init];
        _addModel.type = HXPhotoModelMediaTypeCamera;
        _addModel.thumbPhoto = [MiOPhohoTools hx_imageNamed:@"compose_pic_add@2x.png"];
    }
    return _addModel;
}

- (NSMutableArray *)networkPhotos {
    if (!_networkPhotos) {
        _networkPhotos = [NSMutableArray array];
    }
    return _networkPhotos;
}

+ (instancetype)photoManager:(MiOPhotoManager *)manager {
    return [[self alloc] initWithManager:manager];
}

- (instancetype)initWithFrame:(CGRect)frame WithManager:(MiOPhotoManager *)manager {
    self = [super initWithFrame:frame];
    if (self) {
        self.manager = manager;
        [self setup];
    }
    return self;
}

- (instancetype)initWithManager:(MiOPhotoManager *)manager {
    self = [super init];
    if (self) {
        self.manager = manager;
        [self setup];
    }
    return self;
}

- (void)setup {
    self.numOfLinesOld = 0;
    self.tag = 9999;
    [self.dataList addObject:self.addModel];
    
    self.flowLayout.minimumLineSpacing = Spacing;
    self.flowLayout.minimumInteritemSpacing = Spacing;
    MiOCollectionView *collectionView = [[MiOCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
    collectionView.tag = 8888;
    collectionView.scrollEnabled = NO;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.backgroundColor = self.backgroundColor;
    [collectionView registerClass:[MiOPhotoSubViewCell class] forCellWithReuseIdentifier:@"cellId"];
    [self addSubview:collectionView];
    self.collectionView = collectionView;
    if (self.manager.networkPhotoUrls.count) {
        self.collectionView.editEnabled = NO;
        [self.networkPhotos removeAllObjects];
        for (int i = 0; i < self.manager.networkPhotoUrls.count ; i++) {
            MiOPhotoModel *model = [[MiOPhotoModel alloc] init];
            model.type = HXPhotoModelMediaTypeCameraPhoto;
            model.networkPhotoUrl = self.manager.networkPhotoUrls[i];
            model.cameraIdentifier = [self videoOutFutFileName];
            model.imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width);
            model.selected = YES;
            model.thumbPhoto = [MiOPhohoTools hx_imageNamed:@"qz_photolist_picture_fail@2x.png"];
            model.previewPhoto = model.thumbPhoto;
            [self.networkPhotos addObject:model];
        }
    }
    if (self.manager.endSelectedList.count > 0 || self.networkPhotos.count > 0) {
        [self photoViewControllerDidNext:self.manager.endSelectedList.mutableCopy Photos:self.manager.endSelectedPhotos.mutableCopy Videos:self.manager.endSelectedVideos.mutableCopy Original:self.manager.endIsOriginal];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.manager setPhotoLibraryDidChangeWithPhotoView:^(NSArray *collectionChanges, BOOL selectPhoto){
        [weakSelf photoLibraryDidChange:collectionChanges selectPhoto:selectPhoto];
    }];
}
- (void)photoLibraryDidChange:(NSArray *)list selectPhoto:(BOOL)selectPhoto {
    for (int i = 0; i < list.count ; i++) {
        NSDictionary *dic = list[i];
        PHFetchResultChangeDetails *collectionChanges = dic[@"collectionChanges"];
        MiOAlbumModel *albumModel = dic[@"model"];
        if (collectionChanges) {
            if ([collectionChanges hasIncrementalChanges]) {
                PHFetchResult *result = collectionChanges.fetchResultAfterChanges;
                
                if (collectionChanges.insertedObjects.count > 0) {
                    if (!selectPhoto) {
                        albumModel.asset = nil;
                        albumModel.result = result;
                        albumModel.count = result.count;
                    }
                    if (i == 0) {
                        if (self.manager.cameraPhoto) {
                            PHAsset *asset = collectionChanges.insertedObjects.firstObject;
                            MiOPhotoModel *photoModel = [[MiOPhotoModel alloc] init];
                            photoModel.albumName = albumModel.albumName;
                            photoModel.asset = asset;
                            photoModel.thumbPhoto = self.tempCameraImage;
                            photoModel.previewPhoto = self.tempCameraImage;
                            if (asset.mediaType == PHAssetMediaTypeImage) {
                                if ([[asset valueForKey:@"filename"] hasSuffix:@"GIF"]) {
                                    if (self.manager.singleSelected && self.manager.singleSelecteClip) {
                                        photoModel.type = HXPhotoModelMediaTypePhoto;
                                    }else {
                                        photoModel.type = self.manager.lookGifPhoto ? HXPhotoModelMediaTypePhotoGif : HXPhotoModelMediaTypePhoto;
                                    }
                                }else {
                                    if (iOS9Later) {
                                        if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
                                            if (!self.manager.singleSelected) {
                                                photoModel.type = self.manager.lookLivePhoto ? HXPhotoModelMediaTypeLivePhoto : HXPhotoModelMediaTypePhoto;
                                            }else {
                                                photoModel.type = HXPhotoModelMediaTypePhoto;
                                            }
                                        }else {
                                            photoModel.type = HXPhotoModelMediaTypePhoto;
                                        }
                                    }else {
                                        photoModel.type = HXPhotoModelMediaTypePhoto;
                                    }
                                }
                                [self.manager.endSelectedPhotos addObject:photoModel];
                            }else if (asset.mediaType == PHAssetMediaTypeVideo) {
                                photoModel.type = HXPhotoModelMediaTypeVideo;
                                [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                                    photoModel.avAsset = asset;
                                }];
                                NSString *timeLength = [NSString stringWithFormat:@"%0.0f",asset.duration];
                                photoModel.videoTime = [MiOPhohoTools getNewTimeFromDurationSecond:timeLength.integerValue];
                                [self.manager.endSelectedVideos addObject:photoModel];
                            }
                            photoModel.currentAlbumIndex = albumModel.index;
                            [self.manager.endSelectedList addObject:photoModel];
                            [self photoViewControllerDidNext:self.manager.endSelectedList.mutableCopy Photos:self.manager.endSelectedPhotos.mutableCopy Videos:self.manager.endSelectedVideos.mutableCopy Original:self.manager.endIsOriginal];
                            self.manager.cameraPhoto = NO;
                        }
                    }
                }
                if (collectionChanges.removedObjects.count > 0) {
                    if (!selectPhoto) {
                        albumModel.asset = nil;
                        albumModel.result = result;
                        albumModel.count = result.count;
                    }
                    if (i == 0) {
                        for (PHAsset *asset in collectionChanges.removedObjects) {
                            NSString *property = @"asset";
                            NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K = %@", property, asset];
                            NSArray *newArray = [self.manager.endSelectedList filteredArrayUsingPredicate:pred];
                            if (newArray.count > 0) {
                                MiOPhotoModel *photoModel = newArray.firstObject;
                                if ((photoModel.type == HXPhotoModelMediaTypePhoto || photoModel.type == HXPhotoModelMediaTypePhotoGif) || photoModel.type == HXPhotoModelMediaTypeLivePhoto) {
                                    [self.manager.endSelectedPhotos removeObject:photoModel];
                                }else {
                                    [self.manager.endSelectedVideos removeObject:photoModel];
                                }
                                [self.manager.endSelectedList removeObject:photoModel];
                            }
                        }
                        if (self.manager.endSelectedList.count == 0) {
                            self.manager.endIsOriginal = NO;
                        }
                        [self photoViewControllerDidNext:self.manager.endSelectedList.mutableCopy Photos:self.manager.endSelectedPhotos.mutableCopy Videos:self.manager.endSelectedVideos.mutableCopy Original:self.manager.endIsOriginal];
                    }
                }
                if (collectionChanges.changedObjects.count > 0) {
                    
                }
                if ([collectionChanges hasMoves]) {
                    
                }
            }
        }
    }
}
- (void)setManager:(MiOPhotoManager *)manager {
    _manager = manager;
    [self.networkPhotos removeAllObjects];
    if (self.manager.networkPhotoUrls.count) {
        self.collectionView.editEnabled = NO;
        for (int i = 0; i < self.manager.networkPhotoUrls.count ; i++) {
            MiOPhotoModel *model = [[MiOPhotoModel alloc] init];
            model.type = HXPhotoModelMediaTypeCameraPhoto;
            model.networkPhotoUrl = self.manager.networkPhotoUrls[i];
            model.cameraIdentifier = [self videoOutFutFileName];
            model.imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width);
            model.selected = YES;
            model.thumbPhoto = [MiOPhohoTools hx_imageNamed:@"qz_photolist_picture_fail@2x.png"];
            model.previewPhoto = model.thumbPhoto;
            [self.networkPhotos addObject:model];
        }
    }
    if (self.manager.endSelectedList.count > 0 || self.networkPhotos.count > 0) {
        [self photoViewControllerDidNext:self.manager.endSelectedList.mutableCopy Photos:self.manager.endSelectedPhotos.mutableCopy Videos:self.manager.endSelectedVideos.mutableCopy Original:self.manager.endIsOriginal];
    }
}
- (void)refreshView {
    [self photoViewControllerDidNext:self.manager.endSelectedList.mutableCopy Photos:self.manager.endSelectedPhotos.mutableCopy Videos:self.manager.endSelectedVideos.mutableCopy Original:self.manager.endIsOriginal];
}
- (NSString *)videoOutFutFileName {
    NSString *fileName = @"";
    NSDate *nowDate = [NSDate date];
    NSString *dateStr = [NSString stringWithFormat:@"%ld", (long)[nowDate timeIntervalSince1970]];
    NSString *numStr = [NSString stringWithFormat:@"%d",arc4random()%10000];
    fileName = [fileName stringByAppendingString:dateStr];
    fileName = [fileName stringByAppendingString:numStr];
    return fileName;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MiOPhotoSubViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellId" forIndexPath:indexPath];
    cell.model = self.dataList[indexPath.item];
    cell.delegate = self;
    cell.showDeleteNetworkPhotoAlert = self.manager.showDeleteNetworkPhotoAlert;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.currentIndexPath = indexPath;
    MiOPhotoModel *model = self.dataList[indexPath.item];
    if (model.networkPhotoUrl.length > 0) {
        if (!model.downloadComplete) {
            [[self viewController:self].view showImageHUDText:[NSBundle hx_localizedStringForKey:@"照片正在下载"]];
            return;
        }else if (model.downloadError) {
            MiOPhotoSubViewCell *cell = (MiOPhotoSubViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            [cell againDownload];
            return;
        }
    }
    if (model.type == HXPhotoModelMediaTypeCamera) {
        [self goPhotoViewController];
    }else if ((model.type == HXPhotoModelMediaTypePhoto || model.type == HXPhotoModelMediaTypePhotoGif) || (model.type == HXPhotoModelMediaTypeCameraPhoto || model.type == HXPhotoModelMediaTypeLivePhoto)) {
        MiOPhotoPreviewViewController *vc = [[MiOPhotoPreviewViewController alloc] init];
        vc.selectedComplete = YES;
        vc.modelList = self.photos;
        vc.index = model.endIndex;
        vc.manager = self.manager;
        vc.photoView = self;
        [[self viewController:self] presentViewController:vc animated:YES completion:nil];
    }else if (model.type == HXPhotoModelMediaTypeVideo){
        MiOVideoPreviewViewController *vc = [[MiOVideoPreviewViewController alloc] init];
        vc.manager = self.manager;
        vc.model = model;
        vc.selectedComplete = YES;
        vc.photoView = self;
        [[self viewController:self] presentViewController:vc animated:YES completion:nil];
    }else if (model.type == HXPhotoModelMediaTypeCameraVideo) {
        MiOVideoPreviewViewController *vc = [[MiOVideoPreviewViewController alloc] init];
        vc.manager = self.manager;
        vc.model = model;
        vc.isCamera = YES;
        vc.selectedComplete = YES;
        vc.photoView = self;
        [[self viewController:self] presentViewController:vc animated:YES completion:nil];
    }
}

- (void)goCamera {
    self.manager.goCamera = YES;
    [self goPhotoViewController];
}

- (void)goPhotoViewController {
    if (self.manager.outerCamera) {
        self.manager.openCamera = NO;
        if (self.manager.networkPhotoUrls.count == 0) {
            if (self.manager.type == MiOPhotoManagerSelectedTypePhoto) {
                self.manager.maxNum = self.manager.photoMaxNum;
            }else if (self.manager.type == MiOPhotoManagerSelectedTypeVideo) {
                self.manager.maxNum = self.manager.videoMaxNum;
            }else {
                // 防错
                if (self.manager.videoMaxNum + self.manager.photoMaxNum != self.manager.maxNum) {
                    self.manager.maxNum = self.manager.videoMaxNum + self.manager.photoMaxNum;
                }
            }
        }
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:[NSBundle hx_localizedStringForKey:@"取消"] destructiveButtonTitle:nil otherButtonTitles:[NSBundle hx_localizedStringForKey:@"相机"],[NSBundle hx_localizedStringForKey:@"相册"], nil];
        
        [sheet showInView:self];
        return;
    }
    MiOPhotoViewController *vc = [[MiOPhotoViewController alloc] init];
    vc.manager = self.manager;
    vc.delegate = self;
    [[self viewController:self] presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [[self viewController:self].view showImageHUDText:[NSBundle hx_localizedStringForKey:@"无法使用相机!"]];
            return;
        }
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSBundle hx_localizedStringForKey:@"无法使用相机"] message:[NSBundle hx_localizedStringForKey:@"请在设置-隐私-相机中允许访问相机"] delegate:self cancelButtonTitle:[NSBundle hx_localizedStringForKey:@"取消"] otherButtonTitles:[NSBundle hx_localizedStringForKey:@"设置"], nil];
            [alert show];
            return;
        }
        HXCameraType type = 0;
        if (self.manager.type == MiOPhotoManagerSelectedTypePhotoAndVideo) {
            if (self.videos.count >= self.manager.videoMaxNum && self.photos.count < self.manager.photoMaxNum + self.networkPhotos.count) {
                type = HXCameraTypePhoto;
            }else if (self.photos.count >= self.manager.photoMaxNum + self.networkPhotos.count && self.videos.count < self.manager.videoMaxNum) {
                type = HXCameraTypeVideo;
            }else if (self.photos.count + self.videos.count >= self.manager.maxNum + self.networkPhotos.count) {
                [[self viewController:self].view showImageHUDText:[NSBundle hx_localizedStringForKey:@"已达最大数!"]];
                return;
            }else {
                type = HXCameraTypePhotoAndVideo;
            }
        }else if (self.manager.type == MiOPhotoManagerSelectedTypePhoto) {
            if (self.photos.count >= self.manager.photoMaxNum + self.networkPhotos.count) {
                [[self viewController:self].view showImageHUDText:[NSBundle hx_localizedStringForKey:@"照片已达最大数!"]];
                return;
            }
            type = HXCameraTypePhoto;
        }else if (self.manager.type == MiOPhotoManagerSelectedTypeVideo) {
            if (self.videos.count >= self.manager.videoMaxNum) {
                [[self viewController:self].view showImageHUDText:[NSBundle hx_localizedStringForKey:@"视频已达最大数!"]];
                return;
            }
            type = HXCameraTypeVideo;
        }
        if (self.manager.showFullScreenCamera) {
            MiOFullScreenCameraViewController *vc1 = [[MiOFullScreenCameraViewController alloc] init];
            vc1.delegate = self;
            vc1.type = type;
            vc1.photoManager = self.manager;
            if (self.manager.singleSelected) {
                [[self viewController:self] presentViewController:[[UINavigationController alloc] initWithRootViewController:vc1] animated:YES completion:nil];
            }else {
                [[self viewController:self] presentViewController:vc1 animated:YES completion:nil];
            }
        }else {
            MiOCameraViewController *vc = [[MiOCameraViewController alloc] init];
            vc.delegate = self;
            vc.type = type;
            vc.photoManager = self.manager;
            if (self.manager.singleSelected) {
                [[self viewController:self] presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
            }else {
                [[self viewController:self] presentViewController:vc animated:YES completion:nil];
            }
        }
    }else if (buttonIndex == 1){
        MiOPhotoViewController *vc = [[MiOPhotoViewController alloc] init];
        vc.manager = self.manager;
        vc.delegate = self;
        [[self viewController:self] presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}
- (void)fullScreenCameraDidNextClick:(MiOPhotoModel *)model {
    [self cameraDidNextClick:model];
}

- (void)cameraDidNextClick:(MiOPhotoModel *)model {
    if (self.manager.saveSystemAblum) {
        if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[self viewController:self].view showImageHUDText:[NSBundle hx_localizedStringForKey:@"保存失败，无法访问照片\n请前往设置中允许访问照片"]];
            });
            return;
        }
        self.tempCameraImage = model.thumbPhoto;
        self.manager.cameraPhoto = YES;
        __weak typeof(self) weakSelf = self;
        if (model.type == HXPhotoModelMediaTypeCameraPhoto) {
            [MiOPhohoTools saveImageToAlbum:model.previewPhoto completion:^{
                NSSLog(@"保存成功");
            } error:^{
                weakSelf.manager.cameraPhoto = YES;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[weakSelf viewController:weakSelf].view showImageHUDText:[NSBundle hx_localizedStringForKey:@"照片保存失败!"]];
                });
            }];
        }else {
            [MiOPhohoTools saveVideoToAlbum:model.videoURL completion:^{
                NSSLog(@"保存成功");
            } error:^{
                weakSelf.manager.cameraPhoto = YES;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[weakSelf viewController:weakSelf].view showImageHUDText:[NSBundle hx_localizedStringForKey:@"视频保存失败!"]];
                });
            }];
        }
        return;
    }
    // 判断类型
    if (model.type == HXPhotoModelMediaTypeCameraPhoto) {
        [self.manager.endCameraPhotos addObject:model];
        // 当选择图片个数没有达到最大个数时就添加到选中数组中
        if (self.manager.endSelectedPhotos.count != self.manager.photoMaxNum) {
            if (!self.manager.selectTogether) {
                if (self.manager.endSelectedList.count > 0) {
                    MiOPhotoModel *phMd = self.manager.endSelectedList.firstObject;
                    if ((phMd.type == HXPhotoModelMediaTypePhoto || phMd.type == HXPhotoModelMediaTypeLivePhoto) || (phMd.type == HXPhotoModelMediaTypePhotoGif || phMd.type == HXPhotoModelMediaTypeCameraPhoto)) {
                        [self.manager.endSelectedCameraPhotos insertObject:model atIndex:0];
                        [self.manager.endSelectedPhotos addObject:model];
                        [self.manager.endSelectedList addObject:model];
                        [self.manager.endSelectedCameraList addObject:model];
                        model.selected = YES;
                    }
                }else {
                    [self.manager.endSelectedCameraPhotos insertObject:model atIndex:0];
                    [self.manager.endSelectedPhotos addObject:model];
                    [self.manager.endSelectedList addObject:model];
                    [self.manager.endSelectedCameraList addObject:model];
                    model.selected = YES;
                }
            }else {
                [self.manager.endSelectedCameraPhotos insertObject:model atIndex:0];
                [self.manager.endSelectedPhotos addObject:model];
                [self.manager.endSelectedList addObject:model];
                [self.manager.endSelectedCameraList addObject:model];
                model.selected = YES;
            }
        }
    }else if (model.type == HXPhotoModelMediaTypeCameraVideo) {
        [self.manager.endCameraVideos addObject:model];
        // 当选中视频个数没有达到最大个数时就添加到选中数组中
        if (self.manager.endSelectedVideos.count != self.manager.videoMaxNum) {
            if (!self.manager.selectTogether) {
                if (self.manager.endSelectedList.count > 0) {
                    MiOPhotoModel *phMd = self.manager.endSelectedList.firstObject;
                    if (phMd.type == HXPhotoModelMediaTypeVideo || phMd.type == HXPhotoModelMediaTypeCameraVideo) {
                        [self.manager.endSelectedCameraVideos insertObject:model atIndex:0];
                        [self.manager.endSelectedVideos addObject:model];
                        [self.manager.endSelectedList addObject:model];
                        [self.manager.endSelectedCameraList addObject:model];
                        model.selected = YES;
                    }
                }else {
                    
                    [self.manager.endSelectedCameraVideos insertObject:model atIndex:0];
                    [self.manager.endSelectedVideos addObject:model];
                    [self.manager.endSelectedList addObject:model];
                    [self.manager.endSelectedCameraList addObject:model];
                    model.selected = YES;
                }
            }else {
                [self.manager.endSelectedCameraVideos insertObject:model atIndex:0];
                [self.manager.endSelectedVideos addObject:model];
                [self.manager.endSelectedList addObject:model];
                [self.manager.endSelectedCameraList addObject:model];
                model.selected = YES;
            }
        }
    }
    [self.manager.endCameraList addObject:model];
    [self photoViewControllerDidNext:self.manager.endSelectedList.mutableCopy Photos:self.manager.endSelectedPhotos.mutableCopy Videos:self.manager.endSelectedVideos.mutableCopy Original:self.manager.endIsOriginal];
}
- (void)cellNetworkingPhotoDownLoadComplete {
    if ([self networkingPhotoDownloadComplete] && !self.downLoadComplete) {
        self.downLoadComplete = YES;
        [self photoViewControllerDidNext:self.manager.endSelectedList.mutableCopy Photos:self.manager.endSelectedPhotos.mutableCopy Videos:self.manager.endSelectedVideos.mutableCopy Original:self.manager.endIsOriginal];
        if ([self.delegate respondsToSelector:@selector(photoViewAllNetworkingPhotoDownloadComplete:)]) {
            [self.delegate photoViewAllNetworkingPhotoDownloadComplete:self];
        }
    }
}
- (void)cellDidDeleteClcik:(UICollectionViewCell *)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    MiOPhotoModel *model = self.dataList[indexPath.item];
    [self.manager deleteSpecifiedModel:model];
    if (model.networkPhotoUrl.length > 0) {
        for (MiOPhotoModel *netModel in self.networkPhotos) {
            if ([netModel.networkPhotoUrl isEqualToString:model.networkPhotoUrl]) {
                if ([self.delegate respondsToSelector:@selector(photoView:deleteNetworkPhoto:)]) {
                    [self.delegate photoView:self deleteNetworkPhoto:model.networkPhotoUrl];
                }
                self.manager.photoMaxNum += 1;
                [self.networkPhotos removeObject:netModel];
                break;
            }
        }
    }
    if ((model.type == HXPhotoModelMediaTypePhoto || model.type == HXPhotoModelMediaTypePhotoGif) || (model.type == HXPhotoModelMediaTypeCameraPhoto || model.type == HXPhotoModelMediaTypeLivePhoto)) {
        [self.photos removeObject:model];
    }else if (model.type == HXPhotoModelMediaTypeVideo || model.type == HXPhotoModelMediaTypeCameraVideo) {
        [self.videos removeObject:model];
    }
    model.thumbPhoto = nil;
    model.previewPhoto = nil;
    model.imageData = nil;
    model.livePhoto = nil;
    model = nil;
    
    UIView *mirrorView = [cell snapshotViewAfterScreenUpdates:NO];
    mirrorView.frame = cell.frame;
    [self.collectionView insertSubview:mirrorView atIndex:0];
    cell.hidden = YES;
    [UIView animateWithDuration:0.25 animations:^{
        mirrorView.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
    } completion:^(BOOL finished) {
        cell.hidden = NO;
        [mirrorView removeFromSuperview];
    }];
    [self.dataList removeObjectAtIndex:indexPath.item];
    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    [self changeSelectedListModelIndex];
    if (self.isAddModel) {
        if ([self.delegate respondsToSelector:@selector(photoView:changeComplete:photos:videos:original:)]) {
            [self.delegate photoView:self changeComplete:self.dataList photos:self.photos videos:self.videos original:self.original];
        }
        self.isAddModel = NO;
        [self.dataList addObject:self.addModel];
        [self.collectionView reloadData];
    }else {
        NSMutableArray *array = [NSMutableArray arrayWithArray:self.dataList.mutableCopy];
        [array removeLastObject];
        if ([self.delegate respondsToSelector:@selector(photoView:changeComplete:photos:videos:original:)]) {
            [self.delegate photoView:self changeComplete:array photos:self.photos.mutableCopy videos:self.videos.mutableCopy original:self.original];
        }
    }
    [self setupNewFrame];
}

- (void)changeSelectedListModelIndex {
    int i = 0, j = 0, k = 0;
    NSMutableArray *array;
    if (self.isAddModel) {
        array = self.dataList;
    }else {
        array = self.dataList.mutableCopy;
        [array removeLastObject];
    }
    for (MiOPhotoModel *model in array) {
        if ((model.type == HXPhotoModelMediaTypePhoto || model.type == HXPhotoModelMediaTypePhotoGif) || (model.type == HXPhotoModelMediaTypeCameraPhoto || model.type == HXPhotoModelMediaTypeLivePhoto)) {
            model.endIndex = i++;
        }else if (model.type == HXPhotoModelMediaTypeVideo || model.type == HXPhotoModelMediaTypeCameraVideo) {
            model.endIndex = j++;
        }
        model.endCollectionIndex = k++;
    }
}

- (void)photoViewControllerDidNext:(NSArray<MiOPhotoModel *> *)allList Photos:(NSArray<MiOPhotoModel *> *)photos Videos:(NSArray<MiOPhotoModel *> *)videos Original:(BOOL)original {
//    if ([self.delegate respondsToSelector:@selector(photoViewCurrentSelected:photos:videos:original:)]) {
//        [self.delegate photoViewCurrentSelected:allList photos:photos videos:videos original:original];
//    }
    self.original = original;
    NSMutableArray *tempAllArray = [NSMutableArray array];
    NSMutableArray *tempPhotoArray = [NSMutableArray array];
    for (MiOPhotoModel *model in self.networkPhotos) {
        [tempAllArray addObject:model];
        [tempPhotoArray addObject:model];
    }
    [tempAllArray addObjectsFromArray:allList];
    [tempPhotoArray addObjectsFromArray:photos];
    allList = tempAllArray;
    photos = tempPhotoArray;
    
    self.photos = [NSMutableArray arrayWithArray:photos];
    self.videos = [NSMutableArray arrayWithArray:videos];
    [self.dataList removeAllObjects];
//    if (self.manager.separate) {
//        [self.dataList addObjectsFromArray:photos];
//    }else {

        [self.dataList addObjectsFromArray:allList];
//    }
    [self.dataList addObject:self.addModel];
    if (self.manager.selectTogether) {
        if (self.manager.maxNum == allList.count) {
            [self.dataList removeLastObject];
            self.isAddModel = YES;
        }
    }else {
        if (photos.count > 0) {
            if (photos.count == self.manager.photoMaxNum + self.networkPhotos.count) {
                if (self.manager.photoMaxNum > 0 || self.networkPhotos.count > 0) {
                    [self.dataList removeLastObject];
                    self.isAddModel = YES;
                }
            }
        }else if (videos.count > 0) {
            if (videos.count == self.manager.videoMaxNum) {
                if (self.manager.videoMaxNum > 0) {
                    [self.dataList removeLastObject];
                    self.isAddModel = YES;
                }
            }
        }
//        if (photos.count == self.manager.photoMaxNum + self.networkPhotos.count) {
//            if (self.manager.photoMaxNum > 0 || self.networkPhotos.count > 0) {
//                [self.dataList removeLastObject];
//                self.isAddModel = YES;
//            }
//        }else if (videos.count == self.manager.videoMaxNum) {
//            if (self.manager.videoMaxNum > 0) {
//                [self.dataList removeLastObject];
//                self.isAddModel = YES;
//            }
//        }
    }
    [self changeSelectedListModelIndex];
    [self.collectionView reloadData];
    
    if ([self.delegate respondsToSelector:@selector(photoView:changeComplete:photos:videos:original:)]) {
        [self.delegate photoView:self changeComplete:allList.copy photos:photos.copy videos:videos.copy original:original];
    }
    [self setupNewFrame];
}

- (void)photoViewControllerDidCancel {
    
}

- (NSArray *)dataSourceArrayOfCollectionView:(MiOCollectionView *)collectionView {
    return self.dataList;
}

- (void)dragCellCollectionView:(MiOCollectionView *)collectionView newDataArrayAfterMove:(NSArray *)newDataArray {
    self.dataList = [NSMutableArray arrayWithArray:newDataArray];
}

- (void)dragCellCollectionView:(MiOCollectionView *)collectionView moveCellFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    MiOPhotoModel *fromModel = self.dataList[fromIndexPath.item];
    MiOPhotoModel *toModel = self.dataList[toIndexPath.item];
    [self.manager.endSelectedList removeObject:toModel];
    [self.manager.endSelectedList insertObject:toModel atIndex:toIndexPath.item];
    [self.manager.endSelectedList removeObject:fromModel];
    [self.manager.endSelectedList insertObject:fromModel atIndex:fromIndexPath.item];
    [self.photos removeAllObjects];
    [self.videos removeAllObjects];
    int i = 0, j = 0, k = 0;
    for (MiOPhotoModel *model in self.manager.endSelectedList) {
        if ((model.type == HXPhotoModelMediaTypePhoto || model.type == HXPhotoModelMediaTypePhotoGif) || (model.type == HXPhotoModelMediaTypeCameraPhoto || model.type == HXPhotoModelMediaTypeLivePhoto)) {
            model.endIndex = i++;
            [self.photos addObject:model];
        }else if (model.type == HXPhotoModelMediaTypeVideo || model.type == HXPhotoModelMediaTypeCameraVideo) {
            model.endIndex = j++;
            [self.videos addObject:model];
        }
        model.endCollectionIndex = k++;
    }
    self.manager.endSelectedPhotos = [NSMutableArray arrayWithArray:self.photos];
    self.manager.endSelectedVideos = [NSMutableArray arrayWithArray:self.videos];
}

- (void)dragCellCollectionViewCellEndMoving:(MiOCollectionView *)collectionView {
    if (self.isAddModel) {
        if ([self.delegate respondsToSelector:@selector(photoView:changeComplete:photos:videos:original:)]) {
            [self.delegate photoView:self changeComplete:self.dataList.mutableCopy photos:self.photos.mutableCopy videos:self.videos.mutableCopy original:self.original];
        }
    }else {
        NSMutableArray *array = [NSMutableArray arrayWithArray:self.dataList.mutableCopy];
        [array removeLastObject];
        if ([self.delegate respondsToSelector:@selector(photoView:changeComplete:photos:videos:original:)]) {
            [self.delegate photoView:self changeComplete:array photos:self.photos.mutableCopy videos:self.videos.mutableCopy original:self.original];
        }
    }
}

- (BOOL)networkingPhotoDownloadComplete {
    BOOL complete = YES;
    for (MiOPhotoModel *model in self.networkPhotos) {
        if (!model.downloadComplete || model.downloadError) {
            complete = NO;
            break;
        }
    }
    return complete;
}

- (NSInteger)downloadNumberForNetworkingPhoto {
    NSInteger number = 0;
    for (MiOPhotoModel *model in self.networkPhotos) {
        if (model.downloadComplete && !model.downloadError) {
            number++;
        }
    }
    return number;
}

- (UIViewController*)viewController:(UIView *)view {
    for (UIView* next = [view superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UINavigationController class]] || [nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

- (void)setupNewFrame {
    CGFloat x = self.frame.origin.x;
    CGFloat y = self.frame.origin.y;
    CGFloat width = self.frame.size.width;
    
    CGFloat itemW = (width - Spacing * (LineNum - 1)) / LineNum;
    self.flowLayout.itemSize = CGSizeMake(itemW, itemW);
    
    NSInteger dataCount = self.dataList.count;
    NSInteger numOfLinesNew = (dataCount / LineNum) + 1;
    
    if (dataCount % LineNum == 0) {
        numOfLinesNew -= 1;
    }
    self.flowLayout.minimumLineSpacing = Spacing;
    
    if (numOfLinesNew != self.numOfLinesOld) {
        CGFloat newHeight = numOfLinesNew * itemW + Spacing * (numOfLinesNew - 1);
        self.frame = CGRectMake(x, y, width, newHeight);
        self.numOfLinesOld = numOfLinesNew;
        if (newHeight <= 0) {
            self.numOfLinesOld = 0;
        }
        if ([self.delegate respondsToSelector:@selector(photoView:updateFrame:)]) {
            [self.delegate photoView:self updateFrame:self.frame]; 
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSInteger dataCount = self.dataList.count;
    NSInteger numOfLinesNew = (dataCount / LineNum) + 1;
    
    [self setupNewFrame];
    CGFloat x = self.frame.origin.x;
    CGFloat y = self.frame.origin.y;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    if (dataCount == 1) {
        CGFloat itemW = (width - Spacing * (LineNum - 1)) / LineNum;
        if ((int)height != (int)itemW) {
            self.frame = CGRectMake(x, y, width, itemW);
        }
    }
    if (dataCount % LineNum == 0) {
        numOfLinesNew -= 1;
    }
    CGFloat cWidth = self.frame.size.width;
    CGFloat cHeight = self.frame.size.height;
    self.collectionView.frame = CGRectMake(0, 0, cWidth, cHeight);
    if (cHeight <= 0) {
        self.numOfLinesOld = 0;
        [self setupNewFrame];
        CGFloat cWidth = self.frame.size.width;
        CGFloat cHeight = self.frame.size.height;
        self.collectionView.frame = CGRectMake(0, 0, cWidth, cHeight);
    }
}
- (void)dealloc {
    [[SDWebImageManager sharedManager] cancelAll];
    NSSLog(@"dealloc");
}

@end
