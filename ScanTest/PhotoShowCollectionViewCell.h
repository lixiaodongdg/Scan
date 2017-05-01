//
//  PhotoShowCollectionViewCell.h
//  ScanTest
//
//  Created by QBL on 2017/3/22.
//  Copyright © 2017年 QBL All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoShowCollectionViewCell : UICollectionViewCell
@property(nonatomic,strong)UIImageView *photoImageView;
@property(nonatomic,strong)UIButton *selectedButton;
@property(nonatomic,strong)NSString *cellIndentifier;

@property(nonatomic,copy)void(^seletcedImage)();
@end
