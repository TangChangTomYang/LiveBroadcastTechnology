//
//  LiveBroadCastCameraController.m
//  GPUImageYRDemo
//
//  Created by yangrui on 2018/9/7.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import "LiveBroadCastCameraController.h"
#import <AVKit/AVKit.h> // 播放录制的视频

@interface LiveBroadCastCameraController ()<GPUImageVideoCameraDelegate>


/**美颜相机*/
@property(nonatomic, strong)GPUImageVideoCamera *beatufulCamera;


/**滤镜组*/
@property(nonatomic, strong)GPUImageFilterGroup *filterGroup;
#pragma mark- 各种滤镜
/**磨皮滤镜(祛痘)*/
@property(nonatomic, strong)GPUImageBilateralFilter *bilateralFilter;
/**曝光滤镜*/
@property(nonatomic, strong)GPUImageExposureFilter *exposureFilter;
/**美白滤镜*/
@property(nonatomic, strong)GPUImageBrightnessFilter *brightnessFilter;
/**饱和度*/
@property(nonatomic, strong)GPUImageSaturationFilter *saturationFilter;

#pragma mark- 视频预览
/**视频预览图层*/
@property(nonatomic, strong)GPUImageView *preView;


#pragma mark- 视频存储
@property(nonatomic, strong)GPUImageMovieWriter *movieWriter ;



@property (weak, nonatomic) IBOutlet NSLayoutConstraint *effectToolBottomConstraint;
@end

@implementation LiveBroadCastCameraController

- (GPUImageVideoCamera *)beatufulCamera{
    if (!_beatufulCamera) {
        //sessionPreset 会影响画质,和显示区域的大小
        _beatufulCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionFront];
        // 默认相机方向
        _beatufulCamera.outputImageOrientation =  UIInterfaceOrientationPortrait;
        _beatufulCamera.horizontallyMirrorFrontFacingCamera = YES;
        _beatufulCamera.delegate = self;
    }
    return  _beatufulCamera;
}

-(GPUImageView *)preView{
    if(!_preView){
        _preView = [[GPUImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [self.view addSubview:_preView];
    }
    return _preView;
}

/**磨皮滤镜(祛痘)*/
-(GPUImageBilateralFilter *)bilateralFilter{
    if (!_bilateralFilter) {
       _bilateralFilter = [[GPUImageBilateralFilter alloc] init];
    }
    return _bilateralFilter;
}
/**曝光滤镜*/
-(GPUImageExposureFilter *)exposureFilter{
    if (!_exposureFilter) {
        _exposureFilter = [[GPUImageExposureFilter alloc] init];
    }
    return _exposureFilter;
}
/**美白滤镜*/
-(GPUImageBrightnessFilter *)brightnessFilter{
    if (!_brightnessFilter) {
        _brightnessFilter = [[GPUImageBrightnessFilter alloc]init];
    }
    return _brightnessFilter;
}
/**饱和度*/
-(GPUImageSaturationFilter *)saturationFilter{
    if (!_saturationFilter) {
        _saturationFilter = [[GPUImageSaturationFilter alloc] init];
    }
    return _saturationFilter;
}

-(GPUImageFilterGroup *)filterGroup{
    if (!_filterGroup) {
        _filterGroup = [[GPUImageFilterGroup alloc]init];
        // 设置滤镜的引用关系
        [self.bilateralFilter addTarget:self.brightnessFilter];
        [self.brightnessFilter addTarget:self.exposureFilter];
        [self.exposureFilter addTarget:self.saturationFilter];
        
        // 设置滤镜组的 链初始 和 链终点的filter
        _filterGroup.initialFilters = @[self.bilateralFilter];
        _filterGroup.terminalFilter = self.saturationFilter;
    }
    return _filterGroup;
}




-(GPUImageMovieWriter *)movieWriter{
    if (!_movieWriter) {
        //创建写入对像
        NSString *docment = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *name = [NSString stringWithFormat:@"myMoview_%ld.mp4",(long)[NSDate timeIntervalSinceReferenceDate] ];
        
        NSLog(@"=======name : %@",name);
        NSString *movieFilePath = [docment stringByAppendingPathComponent:name];
        NSURL *fileURl = [NSURL fileURLWithPath:movieFilePath];
        
        _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:fileURl size:[UIScreen mainScreen].bounds.size];
//        // 设置writer 的属性, 是否对视频进行编码
        [_movieWriter setEncodingLiveVideo:YES];
    }
    return _movieWriter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view insertSubview:self.preView atIndex:0];
    // 在GPUIamge 中 target 都是遵守了GPUImageInput 协议的对象,也就是可以往里面输入数据
    // 其实在GPUIamge中,一个target就像是流水线上的一个工位, 这个工位可以是中间的某一环(滤镜或者滤镜组)承上启下,也可以是最后一环.(比如显示,或者写入文件)
    // 当GPUIamge中我们有处理图片,拍照,录制视频,处理已经录制好的视频这四种流水线(功能)
    //(1)GPUImagePicture 代表处理图片流水线第一个工位 ,创建了GPUImagePicture 对象,就确定了第一个工位,就会有输出了, 往后面添加 具体的target 输出即可
    //(2)GPUImageStillCamera 代表处理拍照流水线第一个工位 ,创建了GPUImageStillCamera 对象,就确定了第一个工位,就会有输出了, 往后面添加 具体的target 输出即可
    //(3)GPUImageMovie 代表处理视频流水线第一个工位 ,创建了GPUImagePicture 对象,就确定了第一个工位,就会有输出了, 往后面添加 具体的target 输出即可
    //(4)GPUImageVideoCamera 代表处理录制视频流水线第一个工位 ,创建了GPUImageVideoCamera 对象,就确定了第一个工位,就会有输出了, 往后面添加 具体的target 输出即可
    
   
  
    
    // 1. 给美颜相机添加一个target,把相机中的数据书进去
    // (1)这个target 可以是一个滤镜, 对输入的数据进行处理后会再输出
    // (2)这个target 也可以是一个GPUImageView 只有输入,没有输出(其实输出就是现实画面)
    // (3)这个target 也可以是一个GPUImageMovieWriter,只有输入,没有输出(其实输出就是将数据写入文件)
    [self.beatufulCamera addTarget:self.filterGroup];
    
    // 2. 给滤镜(或者滤镜组)添加target, 滤镜(或者滤镜组)处理后的数据将会输入到这个target 里面
    [self.filterGroup addTarget:self.preView];
    
    
    // 开始采集
    [self.beatufulCamera startCameraCapture];
    
    // 将writer 设置成滤镜组的 target
    [self.filterGroup addTarget:self.movieWriter];
    
    self.beatufulCamera.audioEncodingTarget = self.movieWriter;
    [self.movieWriter startRecording];
    
}



#pragma mark- 交互事件监听
// 停止直播
- (IBAction)stopBtnClick:(id)sender {
    [self.beatufulCamera stopCameraCapture];
    [self.preView removeFromSuperview];
    [self.movieWriter finishRecording];
}

- (IBAction)playMovieBtnClick:(id)sender {
    
    NSURL *url = [self.movieWriter valueForKeyPath:@"movieURL"];
    AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
    AVPlayer *player = [AVPlayer playerWithURL:url];
    playerVC.player = player;
    [self.navigationController presentViewController:playerVC animated:YES completion:nil];
    
    
}

- (IBAction)rotateBtnClick:(id)sender {
    // 切换镜头
    [self.beatufulCamera rotateCamera];
}

- (IBAction)beautifulSwitcherChangeValue:(UISwitch *)switcher {
    if (switcher.isOn == YES) { // 打开美颜
      
//        [self.beatufulCamera removeAllTargets];
 
        [self.beatufulCamera addTarget:self.filterGroup];
        [self.filterGroup addTarget:self.preView];
    }
    else{ // 关闭美颜
//        [self.beatufulCamera removeAllTargets];
        [self.beatufulCamera removeTarget:self.filterGroup];
        [self.beatufulCamera addTarget:self.preView];
    }
}


/** 调整美颜效果*/
- (IBAction)adjustBeatufulEffectBtnClick:(id)sender {
    // 0
    [self  showAdjustView:0];
}

- (IBAction)closeBeatutifulEffectTool:(id)sender {
    //250
     [self  showAdjustView:-250];
}

/** 磨皮效果 磨皮就是距离多远看 */
- (IBAction)bilateralFilterChangeValue:(UISlider *)slider {
    
    CGFloat distanceNormalizationFactor = slider.value * 8.0;
    self.bilateralFilter.distanceNormalizationFactor = distanceNormalizationFactor;
}

//曝光
- (IBAction)exposureFilterChangeValue:(UISlider *)slider {
    //取值 -10 ~ 10,0 是正常
    CGFloat exposure =  (slider.value * 20.0 - 10.0);
    self.exposureFilter.exposure =  exposure;
}

//亮度
- (IBAction)brightnessFilterChangeValue:(UISlider *)slider {
    //取值 -1.0 ~ 1.0,0 是正常
    
    CGFloat brightness =  (slider.value * 2.0 - 1.0);
    self.brightnessFilter.brightness = brightness;
}

//饱和度效果
- (IBAction)saturationFilterChageValue:(UISlider *)slider {
    // 取值 0~2 , 1 是正常值
    CGFloat saturation = slider.value * 2.0;
    self.saturationFilter.saturation = saturation;
}


-(void)showAdjustView:(CGFloat)bottomConst{
    self.effectToolBottomConstraint.constant = bottomConst;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
   
}


#pragma mark- GPUImageVideoCameraDelegate
/** 改代理方法会不停的调用,只要有数据数据就会调用*/
- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    NSLog(@"========美颜相机开始采集画面=========");
}
@end
