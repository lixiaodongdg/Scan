//
//  ScanViewController.m
//  ScanTest
//
//  Created by QBL on 2017/3/16.
//  Copyright © 2017年 QBL All rights reserved.
//
#import "ScanViewController.h"
#import "Masonry.h"
#import "ScanTestUIConfig.h"
#import "ScanView.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "PhotoLibraryViewController.h"

@interface ScanViewController ()<AVCaptureMetadataOutputObjectsDelegate,PhotoLibraryScanResultDelegate>{
    UIAlertController *_messageAlerController;
}
@property(nonatomic,strong)UIView *lineView;
@property(nonatomic,strong)AVCaptureSession *scanCaptureSession;
@property(nonatomic,strong)AVCaptureVideoPreviewLayer *avcLayer;
@property(nonatomic,strong)NSTimer *animtaingTimer;
@property(nonatomic,strong)NSObject *observer;

@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(setExtendedLayoutIncludesOpaqueBars:)]) {
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.title = @"扫一扫";
    [self startScanning];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self scanView];
}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    UIDeviceOrientation currentDeviceOriTation = [UIDevice currentDevice].orientation;
    switch (currentDeviceOriTation) {
        case UIDeviceOrientationLandscapeLeft :UIDeviceOrientationLandscapeLeft:
        {
            self.avcLayer.affineTransform = CGAffineTransformMakeRotation(-M_PI_2);
        }
            break;
        case UIDeviceOrientationLandscapeRight:
        {
            self.avcLayer.affineTransform = CGAffineTransformMakeRotation(M_PI_2);
        }
            break;
        case UIDeviceOrientationPortrait:
        {
            self.avcLayer.affineTransform = CGAffineTransformMakeRotation(0);
        }
            break;
            
        default:
            break;
    }
    self.avcLayer.frame = self.view.layer.bounds;
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.scanView lineStartAnimation];
}
- (UIView *)scanView{
    if (!_scanView) {
        _scanView = [[ScanView alloc]initWithFrame:CGRectZero leftEdge:(CGRectGetWidth(self.view.bounds) * 1 / 5) / 2];
        [self.view addSubview:_scanView];
        [_scanView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.top.and.bottom.equalTo(self.view);
        }];
    }
    return _scanView;
}
- (void)startScanning{
    //创建会话
    self.scanCaptureSession = [[AVCaptureSession alloc]init];
    //获取AVCaptureDevice实例并设置defaultDeviceWithMediaType类型
    AVCaptureDevice *avCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    //初始化输入流
    AVCaptureDeviceInput *avCaptureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:avCaptureDevice error:&error];
    //给会话添加输入流
    [self.scanCaptureSession addInput:avCaptureDeviceInput];
    //创建输出流
    AVCaptureMetadataOutput *avCaptureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    //给会话添加输出流
    [self.scanCaptureSession addOutput:avCaptureMetadataOutput];
    //设置代理
    [avCaptureMetadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //先添加再设置输出的类型
    [avCaptureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    //摄像头图层显示的范围大小
    self.avcLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.scanCaptureSession];
    [self.avcLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.view.layer addSublayer:self.avcLayer];
    [self.scanCaptureSession startRunning];
    //设置扫描的有效范围（默认是全屏，可以不设置）
    /*
    self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureInputPortFormatDescriptionDidChangeNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock: ^(NSNotification *_Nonnull note) {
                                                      avCaptureMetadataOutput.rectOfInterest = [self.avcLayer metadataOutputRectOfInterestForRect:CGRectMake(CGRectGetWidth(self.view.bounds) * 1 / 5 / 2, 80,CGRectGetWidth(self.view.bounds) * 4 / 5,CGRectGetWidth(self.view.bounds) * 4 / 5)];
                                                  }];
     */
    __weak typeof(self) weakSelf = self;
    self.scanView.openFlash = ^(){
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch]) {
            [device lockForConfiguration: nil];
            if (weakSelf.scanView.lightButton.selected) {
                weakSelf.scanView.lightButton.selected = NO;
                [device setTorchMode:AVCaptureTorchModeOff];
            }else{
                weakSelf.scanView.lightButton.selected = YES;
                [device setTorchMode:AVCaptureTorchModeOn];
            }
            [device unlockForConfiguration];
        }

    };
    __block PhotoLibraryViewController *photoLibraryController;
    self.scanView.openPhotoLibrary = ^(){
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        //用户还未做过决定
        if (status == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    //用户允许访问
                    photoLibraryController = [[PhotoLibraryViewController alloc]init];
                    photoLibraryController.scanResultDelegate = weakSelf;
                    UINavigationController *modelNavController = [[UINavigationController alloc]initWithRootViewController:photoLibraryController];
                    [weakSelf presentViewController:modelNavController animated:YES completion:nil];
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf messageAlertController:@"您没赋予本程序相册权限" aletMessage:@"您可以在iOS系统的“设置→隐私→相册”中赋予本程序相册权限" action:@"确定" handler:^(NSInteger buttonIndex) {
                            _messageAlerController = nil;
                        }];
                    });
                }
            }];
            
        }else if(status == PHAuthorizationStatusAuthorized){
            photoLibraryController = [[PhotoLibraryViewController alloc]init];
            photoLibraryController.scanResultDelegate = weakSelf;
            UINavigationController *modelNavController = [[UINavigationController alloc]initWithRootViewController:photoLibraryController];
            [weakSelf presentViewController:modelNavController animated:YES completion:nil];
        }else{
            [weakSelf messageAlertController:@"您没赋予本程序相册权限" aletMessage:@"您可以在iOS系统的“设置→隐私→相册”中赋予本程序相册权限" action:@"确定" handler:^(NSInteger buttonIndex) {
                _messageAlerController = nil;
            }];
            
        }
    };
    
}
#pragma mark -AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (_messageAlerController) {
        return;
    }
    if (metadataObjects.count > 0) {
        [self.scanView lineStopAnimation];
        [self.scanCaptureSession stopRunning];
        AVMetadataMachineReadableCodeObject *metadataMacObj = metadataObjects[0];
        NSString *result = metadataMacObj.stringValue;
        NSLog(@"scnString = %@",result);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self messageAlertController:@"温馨提示" aletMessage:result action:@"cancel" handler:^(NSInteger buttonIndex) {
                _messageAlerController = nil;
                [self.scanCaptureSession startRunning];
                [self.scanView lineStartAnimation];
            }];
        });
    }
}
- (void)messageAlertController:(NSString *)title aletMessage:(NSString *)message action:(NSString *)actionTitle handler:(void (^)(NSInteger buttonIndex))block{
    [self.scanView lineStopAnimation];
    _messageAlerController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alerAction = [UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (block) {
            block(1);
        }
    }];
    [_messageAlerController addAction:alerAction];
    [self presentViewController:_messageAlerController animated:YES completion:nil];
}
- (void)photoLibraryScanResult:(NSString *)result{
    [self.scanView lineStopAnimation];
    [self.scanCaptureSession stopRunning];
    [self messageAlertController:@"温馨提示" aletMessage:result action:@"cancel" handler:^(NSInteger buttonIndex) {
        [self.scanCaptureSession startRunning];
        [self.scanView lineStartAnimation];
        _messageAlerController = nil;
    }];
    
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
}
@end
