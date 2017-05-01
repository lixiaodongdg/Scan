//
//  PhotoLibraryViewController.m
//  ScanTest
//
//  Created by QBL on 2017/3/22.
//  Copyright © 2017年 QBL All rights reserved.
//
#import "PhotoLibraryViewController.h"
#import "Masonry.h"
#import "PhotoShowCollectionViewCell.h"
#import <Photos/Photos.h>
#import "ScanView.h"
static NSString *indentifier = @"photoIndentifier";

@interface PhotoLibraryViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,PHPhotoLibraryChangeObserver>{
    CGSize _targetSize;
    UIImage *_selectedImage;
}
@property(nonatomic,strong)PHFetchResult *photoLibraryResult;
@property(nonatomic,strong)PHCachingImageManager *photoLibraryManager;
@property(nonatomic,strong)UICollectionView *collectionView;

@end

@implementation PhotoLibraryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(setExtendedLayoutIncludesOpaqueBars:)]) {
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.navigationItem.title = @"选择照片";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(dismissVC)];
    [self addPhotoCollectionView];
    [self photoLibrary];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (void)addPhotoCollectionView{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    UICollectionView *photoCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    photoCollectionView.backgroundColor = [UIColor whiteColor];
    photoCollectionView.dataSource = self;
    photoCollectionView.delegate = self;
    flowLayout.minimumLineSpacing = 5;
    flowLayout.minimumInteritemSpacing = 5;
    flowLayout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    flowLayout.itemSize = CGSizeMake((CGRectGetWidth(self.view.bounds) - 5 * 5) / 4, (CGRectGetWidth(self.view.bounds) - 5 * 5) / 4);
    _targetSize = CGSizeMake([UIScreen mainScreen].scale * flowLayout.itemSize.width, [UIScreen mainScreen].scale *flowLayout.itemSize.height);
    [self.view addSubview:photoCollectionView];
    [photoCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.and.bottom.equalTo(self.view);
    }];
    [photoCollectionView registerClass:[PhotoShowCollectionViewCell class] forCellWithReuseIdentifier:indentifier];
}
- (void)photoLibrary{
        if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
            //PHCachingImageManager 图片缓存管理者
            self.photoLibraryManager = [[PHCachingImageManager alloc]init];
            [self.photoLibraryManager stopCachingImagesForAllAssets];
            //注册成为观察者
            [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
            PHFetchOptions *allPhotoOptions = [PHFetchOptions new];
            if ([allPhotoOptions respondsToSelector:@selector(setIncludeAssetSourceTypes:)]) {
                allPhotoOptions.includeAssetSourceTypes = PHAssetSourceTypeUserLibrary;
            }
            //按照创建的时间获取资源
            allPhotoOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            self.photoLibraryResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:allPhotoOptions];
        }
}
#pragma mark -UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.photoLibraryResult.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PhotoShowCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:indentifier forIndexPath:indexPath];
    PHAsset *set = self.photoLibraryResult[indexPath.row];
    //对象(图片)的唯一标识
    cell.cellIndentifier = set.localIdentifier;
    //请求图片
    [self.photoLibraryManager requestImageForAsset:set targetSize:_targetSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage *result, NSDictionary * _Nullable info) {
        if (result) {
            cell.photoImageView.image = result;
        }
    }];
    _selectedImage = nil;
    cell.selectedButton.tag = indexPath.row;
    __weak typeof(cell)  weakCell = cell;
    cell.seletcedImage = ^{
        weakCell.selectedButton.selected = YES;
        _selectedImage = weakCell.photoImageView.image;
        //取出选中的图片
        _selectedImage = [self compressImage:_selectedImage newWidth:256];
        NSData *imageData = UIImagePNGRepresentation(_selectedImage);
        CIImage *ciImage = [CIImage imageWithData:imageData];
        //创建探测器
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorImageOrientation}];
        NSArray *feature = [detector featuresInImage:ciImage];
        NSString *resultString;
        if (feature.count > 0) {
            //取出识别到的数据
            for (CIQRCodeFeature *result in feature) {
                if (result.messageString.length > 0) {
                    resultString = result.messageString;
                }
            }
        }else{
           resultString = @"识别失败";
        }
        if ([self.scanResultDelegate respondsToSelector:@selector(photoLibraryScanResult:)]) {
            [self dismissViewControllerAnimated:YES completion:nil];
            [self.scanResultDelegate photoLibraryScanResult:resultString];
        }
    };
    return cell;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((CGRectGetWidth(self.view.bounds) - 5 * 5) / 4, (CGRectGetWidth(self.view.bounds) - 5 * 5) / 4);
}
#pragma mark -PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance{
    
}
- (UIImage *)compressImage:(UIImage *)image newWidth:(CGFloat)newImageWidth
{
    if (!image) return nil;
    float imageWidth = image.size.width;
    float imageHeight = image.size.height;
    float width = newImageWidth;
    float height = image.size.height / (image.size.width / width);
    
    float widthScale = imageWidth / width;
    float heightScale = imageHeight / height;
    
  
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    if (widthScale > heightScale) {
        [image drawInRect:CGRectMake(0, 0, width , height)];
    }
    else {
        [image drawInRect:CGRectMake(0, 0, width , height)];
    }
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)dealloc{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}
@end
