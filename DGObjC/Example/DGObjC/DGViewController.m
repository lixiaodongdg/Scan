//
//  DGViewController.m
//  DGObjC
//
//  Created by 李晓东 on 05/07/2018.
//  Copyright (c) 2018 李晓东. All rights reserved.
//

#import "DGViewController.h"
#import <DGObjC/CustomUIView.h>

@interface DGViewController ()

@end

@implementation DGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    CustomUIView *customView = [CustomUIView new];
    [customView logView];
    UILabel *label = [[UILabel alloc] init];
    [self.view addSubview:label];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
