//
//  Demo4ViewController.m
//  微博照片选择
//
//  Created by MiO on 2017/7/1.
//  Copyright © 2017年 MiO. All rights reserved.
//

#import "Demo4ViewController.h"
#import "MiOPhotoViewController.h"

@interface Demo4ViewController ()<HXPhotoViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) MiOPhotoManager *manager;
@end

@implementation Demo4ViewController
- (MiOPhotoManager *)manager {
    if (!_manager) {
        _manager = [[MiOPhotoManager alloc] initWithType:MiOPhotoManagerSelectedTypePhoto];
        _manager.openCamera = YES;
        _manager.singleSelected = YES;
//        _manager.singleSelecteClip = NO;
        _manager.showFullScreenCamera = YES;
    }
    return _manager;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)selectedPhoto:(id)sender {
    MiOPhotoViewController *vc = [[MiOPhotoViewController alloc] init];
    vc.manager = self.manager;
    vc.delegate = self;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
}
- (void)photoViewControllerDidNext:(NSArray<MiOPhotoModel *> *)allList Photos:(NSArray<MiOPhotoModel *> *)photos Videos:(NSArray<MiOPhotoModel *> *)videos Original:(BOOL)original { 
    __weak typeof(self) weakSelf = self;
    [MiOPhohoTools getImageForSelectedPhoto:photos type:0 completion:^(NSArray<UIImage *> *images) {
        weakSelf.imageView.image = images.firstObject;
    }];
} 

- (void)photoViewControllerDidCancel {
    
}
 

@end
