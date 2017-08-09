//
//  MiOAlbumListView.h
//  微博照片选择
//
//  Created by MiO on 17/2/8.
//  Copyright © 2017年 MiO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MiOAlbumModel.h"

@protocol HXAlbumListViewDelegate <NSObject>

- (void)didTableViewCellClick:(MiOAlbumModel *)model animate:(BOOL)anim;

@end

@interface MiOAlbumListView : UIView
@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) id<HXAlbumListViewDelegate> delegate;
@property (copy, nonatomic) NSArray *list;
@property (assign, nonatomic) NSInteger currentIndex;
@end

@interface HXAlbumListViewCell : UITableViewCell
@property (strong, nonatomic) MiOAlbumModel *model;
@end
