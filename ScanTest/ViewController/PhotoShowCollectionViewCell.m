//
//  PhotoShowCollectionViewCell.m
//  ScanTest
//
//  Created by QBL on 2017/3/22.
//  Copyright © 2017年 QBL All rights reserved.
//

#import "PhotoShowCollectionViewCell.h"
#import "Masonry.h"
@implementation PhotoShowCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addView];
    }
    return self;
}
- (void)addView{
    self.photoImageView = [UIImageView new];
    [self.contentView addSubview:self.photoImageView];
    [self.photoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.and.bottom.equalTo(self.contentView);
    }];
    
    self.selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.selectedButton setImage:[UIImage imageNamed:@"buImage"] forState:UIControlStateNormal];
    [self.selectedButton addTarget:self action:@selector(selectedImage) forControlEvents:UIControlEventTouchUpInside];
    [self.selectedButton setImage:[UIImage imageNamed:@"selectedBuimage"] forState:UIControlStateSelected];
    [self.contentView addSubview:self.selectedButton];
    [self.selectedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
}
- (void)selectedImage{
    if (self.seletcedImage) {
        self.seletcedImage();
    }
}
@end
