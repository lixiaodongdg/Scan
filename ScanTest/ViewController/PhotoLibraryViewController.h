//
//  PhotoLibraryViewController.h
//  ScanTest
//
//  Created by QBL on 2017/3/22.
//  Copyright © 2017年 QBL All rights reserved.
//

#import <UIKit/UIKit.h>
@class ScanView;
@protocol PhotoLibraryScanResultDelegate  <NSObject>
- (void)photoLibraryScanResult:(NSString *)result;
@end
@interface PhotoLibraryViewController : UIViewController
@property(nonatomic,strong)ScanView *scanView;
@property(nonatomic,weak)id<PhotoLibraryScanResultDelegate> scanResultDelegate;
@end
