//
//  BeautifulCameraController.m
//  GPUImageYRDemo
//
//  Created by yangrui on 2018/9/6.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import "BeautifulCameraController.h"

@interface BeautifulCameraController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

/** 美颜相机 */
@property(nonatomic, strong)GPUImageStillCamera *beautifulCamera;
/**美白滤镜*/
@property(nonatomic, strong)GPUImageBrightnessFilter *brightnessFilter;
/**实时预览画面*/
@property(nonatomic, strong)GPUImageView *preView;
@end

@implementation BeautifulCameraController


-(GPUImageStillCamera *)beautifulCamera{
    if(!_beautifulCamera){
       // AVCaptureSessionPresetHigh 这个是用来决定拍照质量的(像素的大小)
        _beautifulCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionFront];
        // 设置相机的拍照的方向
        _beautifulCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    }
    return _beautifulCamera;
}

- (GPUImageBrightnessFilter *)brightnessFilter{
    if (!_brightnessFilter) {
        _brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
        // 经过测试 0.7 是个比较好的值
        _brightnessFilter.brightness = 0.5;
    }
    return _brightnessFilter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.hidden = YES;
    self.imageView.userInteractionEnabled = YES;
}

-(void)start{
    [self.beautifulCamera addTarget:self.brightnessFilter];
    // 创建GPUImageView 用于显示实时的画面
    GPUImageView *preView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:preView aboveSubview:self.imageView];
    [self.brightnessFilter addTarget:preView];
    self.preView = preView;
    
    // 开始捕捉画面
    [self.beautifulCamera startCameraCapture];
}

-(void)cancle{
    [self.beautifulCamera stopCameraCapture];
    self.beautifulCamera = nil;
    self.brightnessFilter = nil;
    [self.preView removeFromSuperview];
    self.preView = nil;
    self.imageView.hidden = NO;
}

- (IBAction)saveBtnClick:(id)sender {
    __weak typeof(self) weakself = self;
    [self.beautifulCamera capturePhotoAsImageProcessedUpToFilter:self.brightnessFilter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        UIImageWriteToSavedPhotosAlbum(processedImage, nil, nil, nil);
        weakself.imageView.image = processedImage;
    }];
}
- (IBAction)startBtnClick:(id)sender {
    [self start];
}
- (IBAction)cancleBtnClick:(id)sender {
    [self cancle];
}
- (IBAction)slider:(UISlider *)slider {
    self.brightnessFilter.brightness = slider.value;
}

@end
