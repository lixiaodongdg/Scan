//
//  ViewController.m
//  ScanTest
//
//  Created by QBL on 2017/3/16.
//  Copyright © 2017年 QBL All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import "ScanViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(setExtendedLayoutIncludesOpaqueBars:)]) {
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self addView];
}
- (void)addView {
    UIButton *scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [scanButton setTitle:@"扫一扫" forState:UIControlStateNormal];
    [scanButton setBackgroundColor:[UIColor greenColor]];
    [scanButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [scanButton addTarget:self action:@selector(scanButonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scanButton];
    [scanButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(200, 60));
    }];
}
- (void)scanButonClick {
    ScanViewController *scanViewController = [[ScanViewController alloc]init];
    scanViewController.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:scanViewController animated:YES];
}
@end
