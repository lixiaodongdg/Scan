//
//  ScanView.h
//  ScanTest
//
//  Created by QBL on 2017/3/21.
//  Copyright © 2017年 QBL All rights reserved.
//

#import <UIKit/UIKit.h>
@interface ScanView : UIView
@property(nonatomic,strong)UIButton *lightButton;
@property(nonatomic,copy)void(^openPhotoLibrary)();
@property(nonatomic,copy)void(^openFlash)();
- (instancetype)initWithFrame:(CGRect)frame leftEdge:(CGFloat)edge;
- (void)lineStartAnimation;
- (void)lineStopAnimation;
@end
