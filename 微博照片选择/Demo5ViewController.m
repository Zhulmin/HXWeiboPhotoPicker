//
//  Demo5ViewController.m
//  微博照片选择
//
//  Created by MiO on 2017/7/5.
//  Copyright © 2017年 MiO. All rights reserved.
//

#import "Demo5ViewController.h"
#import "MiOPhotoView.h" 
@interface Demo5ViewController ()<HXPhotoViewDelegate>
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) MiOPhotoView *onePhotoView;
@property (strong, nonatomic) MiOPhotoManager *oneManager;
@property (strong, nonatomic) MiOPhotoView *twoPhotoView;
@property (strong, nonatomic) MiOPhotoManager *twoManager;
@property (strong, nonatomic) MiOPhotoView *threePhotoView;
@property (strong, nonatomic) MiOPhotoManager *threeManager;
@end

@implementation Demo5ViewController

- (MiOPhotoManager *)oneManager {
    if (!_oneManager) {
        _oneManager = [[MiOPhotoManager alloc] initWithType:MiOPhotoManagerSelectedTypePhoto];
        
    }
    return _oneManager;
}

- (MiOPhotoManager *)twoManager {
    if (!_twoManager) {
        _twoManager = [[MiOPhotoManager alloc] initWithType:MiOPhotoManagerSelectedTypeVideo];
        
    }
    return _twoManager;
}

- (MiOPhotoManager *)threeManager {
    if (!_threeManager) {
        _threeManager = [[MiOPhotoManager alloc] initWithType:MiOPhotoManagerSelectedTypePhotoAndVideo];
        
    }
    return _threeManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.scrollView];
    
    self.onePhotoView = [[MiOPhotoView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 0) WithManager:self.oneManager];
    self.onePhotoView.delegate = self;
    [self.scrollView addSubview:self.onePhotoView];
    
    self.twoPhotoView = [[MiOPhotoView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.onePhotoView.frame) + 20, self.view.frame.size.width, 0) WithManager:self.twoManager];
    self.twoPhotoView.delegate = self;
    [self.scrollView addSubview:self.twoPhotoView];
    
    self.threePhotoView = [[MiOPhotoView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.twoPhotoView.frame) + 20, self.view.frame.size.width, 0) WithManager:self.threeManager];
    self.threePhotoView.delegate = self;
    [self.scrollView addSubview:self.threePhotoView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清空" style:UIBarButtonItemStylePlain target:self action:@selector(didCleanClick)];
}
- (void)didCleanClick {
    [self.oneManager clearSelectedList];
    [self.twoManager clearSelectedList];
    [self.threeManager clearSelectedList];
    [self.onePhotoView refreshView];
    [self.twoPhotoView refreshView];
    [self.threePhotoView refreshView];
}
- (void)photoView:(MiOPhotoView *)photoView changeComplete:(NSArray<MiOPhotoModel *> *)allList photos:(NSArray<MiOPhotoModel *> *)photos videos:(NSArray<MiOPhotoModel *> *)videos original:(BOOL)isOriginal {
    if (self.onePhotoView == photoView) {
        NSSLog(@"onePhotoView - %@",allList);
    }else if (self.twoPhotoView == photoView) {
        NSSLog(@"twoPhotoView - %@",allList);
    }else if (self.threePhotoView == photoView) {
        NSSLog(@"threePhotoView - %@",allList);
    }
}
- (void)photoView:(MiOPhotoView *)photoView updateFrame:(CGRect)frame {
    if (self.onePhotoView == photoView) {
        self.twoPhotoView.frame = CGRectMake(0, CGRectGetMaxY(self.onePhotoView.frame) + 20, self.view.frame.size.width, self.twoPhotoView.frame.size.height);
        self.threePhotoView.frame = CGRectMake(0, CGRectGetMaxY(self.twoPhotoView.frame) + 20, self.view.frame.size.width, self.threePhotoView.frame.size.height);
    }else if (self.twoPhotoView == photoView) {
        self.twoPhotoView.frame = CGRectMake(0, CGRectGetMaxY(self.onePhotoView.frame) + 20, self.view.frame.size.width, self.twoPhotoView.frame.size.height);
        self.threePhotoView.frame = CGRectMake(0, CGRectGetMaxY(self.twoPhotoView.frame) + 20, self.view.frame.size.width, self.threePhotoView.frame.size.height);
    }else if (self.threePhotoView == photoView) {
        self.threePhotoView.frame = CGRectMake(0, CGRectGetMaxY(self.twoPhotoView.frame) + 20, self.view.frame.size.width, frame.size.height);
    }
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, CGRectGetMaxY(self.threePhotoView.frame) + 100);
}

@end
