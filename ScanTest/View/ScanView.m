//
//  ScanView.m
//  ScanTest
//
//  Created by QBL on 2017/3/21.
//  Copyright © 2017年 QBL All rights reserved.
//

#import "ScanView.h"
#import "Masonry.h"
#import <AVFoundation/AVFoundation.h>
@interface ScanView ()
@property(nonatomic,strong)UIImageView *lineImageView;
@end
@implementation ScanView{
    CGFloat _leftEdge;
    CGSize _scanWindow;
    CGFloat _minX,_maxX,_minY,_maxY,_viewWidth,_viewHeigth;
    CGContextRef _context;
    NSTimer *_animationTimer;
}

- (instancetype)initWithFrame:(CGRect)frame leftEdge:(CGFloat)edge{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _leftEdge = edge;
        [self addlineImageView];
        
    }
    return self;
}
- (void)drawRect:(CGRect)rect{
    
    _scanWindow = CGSizeMake(CGRectGetWidth(self.bounds) - _leftEdge * 2, CGRectGetWidth(self.bounds) - _leftEdge *2);
    _viewWidth = CGRectGetWidth(self.bounds);
    _viewHeigth = CGRectGetHeight(self.bounds);
    _minX = _leftEdge;
    _maxX = _leftEdge + _scanWindow.width;
    _minY = 80;
    _maxY = 80 + _scanWindow.height;
    _context = UIGraphicsGetCurrentContext();
    //绘制遮罩
    [self drawMask];
    //矩形框
    [self drawScanRect];
    NSLog(@"drawrect----Temp");
    
}
- (void)drawMask{
    CGContextSetRGBFillColor(_context,0.5,0.5,0.5,0.5);
    CGRect makeRect = CGRectMake(0, 0, _viewWidth, 80);
    CGContextFillRect(_context, makeRect);
    
    makeRect = CGRectMake(0, _minY, _leftEdge, _scanWindow.height);
    CGContextFillRect(_context, makeRect);
    
    makeRect = CGRectMake(_maxX, _minY, _leftEdge, _scanWindow.height);
    CGContextFillRect(_context, makeRect);
    
    makeRect = CGRectMake(0, _maxY, _viewWidth, _viewHeigth - _scanWindow.height - 80);
    CGContextFillRect(_context, makeRect);

}
- (void)drawScanRect{
    CGContextSetStrokeColorWithColor(_context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(_context, 1);
    CGContextAddRect(_context, CGRectMake(_minX, _minY, _scanWindow.width, _scanWindow.width));
    CGContextStrokePath(_context);
    
    CGFloat lineWidth = 30;
    CGFloat lineHeight = 30;
    CGFloat line_minX = _minX - 8 / 2;
    CGFloat line_maxX = _maxX + 8 / 2;
    CGFloat line_minY = _minY - 8 / 2;
    CGFloat line_maxY = _maxY + 8 / 2;
    
    CGContextSetStrokeColorWithColor(_context, [UIColor blueColor].CGColor);
    CGContextSetLineWidth(_context, 8);
    
    CGContextMoveToPoint(_context, line_minX, line_minY);
    CGContextAddLineToPoint(_context, line_minX + lineWidth, line_minY);
    
    CGContextMoveToPoint(_context, line_minX, line_minY - 4);
    CGContextAddLineToPoint(_context, line_minX, line_minY + lineHeight + 4);
    
    CGContextMoveToPoint(_context, line_minX, line_maxY);
    CGContextAddLineToPoint(_context, line_minX + lineWidth, line_maxY);
    
    CGContextMoveToPoint(_context, line_minX, line_maxY + 4);
    CGContextAddLineToPoint(_context, line_minX, line_maxY - lineHeight - 4);

    CGContextMoveToPoint(_context, line_maxX, line_maxY);
    CGContextAddLineToPoint(_context, line_maxX - lineWidth, line_maxY);

    CGContextMoveToPoint(_context, line_maxX, line_maxY + 4);
    CGContextAddLineToPoint(_context, line_maxX, line_maxY - lineHeight - 4);
    
    CGContextMoveToPoint(_context, line_maxX, line_minY);
    CGContextAddLineToPoint(_context, line_maxX - lineWidth, line_minY);
    
    CGContextMoveToPoint(_context, line_maxX, line_minY - 4);
    CGContextAddLineToPoint(_context, line_maxX, line_minY + lineHeight + 4);


    CGContextStrokePath(_context);
}
- (void)addlineImageView{
    _lineImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line"]];
    [self addSubview:_lineImageView];
    [_lineImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.mas_top).with.offset(80);
        make.left.equalTo(self.mas_left).with.offset(_leftEdge);
        make.right.equalTo(self.mas_right).with.offset(-_leftEdge);

    }];
    NSLog(@"Temp1111111111111");
    UILabel *reminderLabel = [UILabel new];
    reminderLabel.text = @"将取景框对准二维码即可自动扫描";
    reminderLabel.textAlignment = NSTextAlignmentCenter;
    reminderLabel.textColor = [UIColor whiteColor];
    [self addSubview:reminderLabel];
    [reminderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.centerX.equalTo(self.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(300, 40));
    }];
    NSLog(@"Temp22222222222222");
    UIView *barView = [UIView new];
    barView.backgroundColor = [UIColor blackColor];
    [self addSubview:barView];
    [barView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(150);
    }];
    
    UIButton *photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [photoButton setImage:[UIImage imageNamed:@"photo"] forState:UIControlStateNormal];
    [photoButton addTarget:self action:@selector(openPhotoLibraryClick) forControlEvents:UIControlEventTouchUpInside];
    [barView addSubview:photoButton];
    [photoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(barView.mas_centerY);
        make.centerX.mas_equalTo(-100);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    
    _lightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_lightButton setImage:[UIImage imageNamed:@"lightnormal"] forState:UIControlStateNormal];
    [_lightButton setImage:[UIImage imageNamed:@"light"] forState:UIControlStateSelected];
    [_lightButton addTarget:self action:@selector(openFlashClick) forControlEvents:UIControlEventTouchUpInside];
    [barView addSubview:_lightButton];
    [_lightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(barView.mas_centerY);
        make.centerX.mas_equalTo(100);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    NSLog(@"Temp333333333333333333");
}
- (void)lineStartAnimation{
    if (!_animationTimer) {
        _animationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(animation) userInfo:nil repeats:YES];
    }
}
- (void)animation{
    [_lineImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.mas_top).with.offset(80 + _scanWindow.height - 10);
        make.left.equalTo(self.mas_left).with.offset(_leftEdge);
        make.right.equalTo(self.mas_right).with.offset(-_leftEdge);
    }];
    [UIView animateWithDuration:1 animations:^{
        _lineImageView.hidden = NO;
        [self setNeedsLayout];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.lineImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.top.equalTo(self.mas_top).with.offset(80);
            make.left.equalTo(self.mas_left).with.offset(_leftEdge);
            make.right.equalTo(self.mas_right).with.offset(-_leftEdge);
        }];
        _lineImageView.hidden = YES;
    }];
}
- (void)lineStopAnimation{
    _lineImageView.hidden = YES;
    [_animationTimer invalidate];
    _animationTimer = nil;
}
- (void)openPhotoLibraryClick{
    if (self.openPhotoLibrary) {
        self.openPhotoLibrary();
    }
}
- (void)openFlashClick{
    if (self.openFlash){
        self.openFlash();
    }
}
@end
