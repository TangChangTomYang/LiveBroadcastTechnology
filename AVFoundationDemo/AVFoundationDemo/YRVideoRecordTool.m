//
//  YRVideoRecordTool.m
//  live
//
//  Created by yangrui on 2018/9/3.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import "YRVideoRecordTool.h"
#import <AVFoundation/AVFoundation.h>

@interface YRVideoRecordTool ()
<AVCaptureVideoDataOutputSampleBufferDelegate,
AVCaptureAudioDataOutputSampleBufferDelegate,
AVCaptureFileOutputRecordingDelegate>

@property(nonatomic, strong)AVCaptureSession *session;
@property(nonatomic, strong)AVCaptureDeviceInput *videoInput;
@property(nonatomic, strong)AVCaptureVideoDataOutput *videoOutput;
@property(nonatomic, strong)AVCaptureMovieFileOutput *movieFileOutput;

/** 预览layer的父layer*/
@property(nonatomic, weak)CALayer *parentLayer;
@property(nonatomic, assign)BOOL needSaveRecord;
@property(nonatomic, strong)dispatch_queue_t outputQueue;
@end


static YRVideoRecordTool *_videoTool = nil;
@implementation YRVideoRecordTool

+(instancetype)shareVideoTool{
    if (!_videoTool) {
        _videoTool = [[YRVideoRecordTool alloc] init];
    }
    return _videoTool;
}

/** 开始直播*/
-(void)startLive{
    [self.session startRunning];
}
/** 停止直播*/
-(void)stopLive{
    // 停止视频采集
    [self.session stopRunning];
}

/** 开始 录屏*/
-(void)startRecord{
    [self.session startRunning];
}

/** 停止 录屏*/
-(void)stopRecord{
    if(self.movieFileOutput){
        // 停止视频录制
        [self.movieFileOutput stopRecording];
        self.movieFileOutput = nil;
    }
    // 停止视频采集
    [self.session stopRunning];
}


/** 切换摄像头 */
-(BOOL)rotateCamera{
    // 获取之前设备的方向
    if(self.videoInput == nil){
        NSLog(@"当前还没开始录制视频, 切换摄像头失败");
        return NO;
    }
    
    AVCaptureDevicePosition position = AVCaptureDevicePositionFront;
    if( self.videoInput.device.position == AVCaptureDevicePositionFront){
        position = AVCaptureDevicePositionBack;
    }
    
    NSArray<AVCaptureDevice *> *devArr =  [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *targetDev = nil;
    for(AVCaptureDevice *dev in devArr){
        if (dev.position == position) {
            targetDev = dev;
            break;
        }
    }
    
    NSError *err = nil;
    AVCaptureDeviceInput *newDevInput = [AVCaptureDeviceInput deviceInputWithDevice:targetDev error:&err];
    if (err != nil) {
        NSLog(@"切换摄像头时错误,err:%@",err);
        return NO;
    }
    
    // 开启配置
    [self.session beginConfiguration];
    // 切换摄像头需要先将原来的输入源移除
    [self.session removeInput:self.videoInput];
    
    if(![self.session canAddInput:newDevInput]){
        
        [self.session commitConfiguration];
        NSLog(@"切换摄像头时错误失败err:%@",err);
        return NO;
    }
    [self.session addInput:newDevInput];
    [self.session commitConfiguration];
    
    // 切换新记录
    self.videoInput = newDevInput;
    return YES;
}


-(BOOL)setupLiveVideoWithParentLayer:(CALayer *)parentLayer{
   
    [self reset];
    
    self.parentLayer = parentLayer;
    self.session =  [[AVCaptureSession alloc] init];
    self.outputQueue = dispatch_get_global_queue(0, 0);
    
    [self setupLiveVideoInputOutput];
    //预览图层
    [self setupPreviewLayer];

    return YES;
}

-(BOOL)setupRecordVideoWithParentLayer:(CALayer *)parentLayer{
    
    [self reset];
    
    self.parentLayer = parentLayer;
    self.session =  [[AVCaptureSession alloc] init];
    self.outputQueue = dispatch_get_global_queue(0, 0);
    
    [self setupRecordVideoInputOutput];
    //预览图层
    [self setupPreviewLayer];
    
    return YES;
}

#pragma mark- 私有方法
-(void)reset{
    self.session = nil;
    self.videoInput = nil;
    self.videoOutput = nil;
    self.movieFileOutput = nil;
    
    /** 预览layer的父layer*/
    self.parentLayer = nil;
    self.outputQueue = nil;
}

-(BOOL)setupLiveVideoInputOutput{
    // 1. 添加视频输入源
    if(![self setupVideoInput]){
        return NO;
    }
    
    //2. 添加视频输出源
    return  [self setupLiveVideoOutput];
}

-(BOOL)setupRecordVideoInputOutput{
    // 1. 添加视频输入源
    if(![self setupVideoInput]){
        return NO;
    }
    
    [self setupLiveVideoOutput];
    
    return YES;
    //2. 添加输出源 保存视频
    //3  添加就报错 问题一直没解决???
    return  [self setupMovieFileOutput];
}


-(BOOL)setupVideoInput{
    //1. 获取当前的摄像头(所有)
    NSArray<AVCaptureDevice *> *devArr = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    //2. 获取前摄
    AVCaptureDevice *camera = nil;
    for (AVCaptureDevice *dev in devArr) {
        if (dev.position == AVCaptureDevicePositionFront) {
            camera = dev;
            NSLog(@"获取前置摄像头 成功");
            break;
        }
    }
    if (camera == nil) {
        NSLog(@"获取前置摄像头失败, 尝试获取后摄");
        for (AVCaptureDevice *dev in devArr) {
            if (dev.position == AVCaptureDevicePositionBack) {
                camera = dev;
                NSLog(@"获取后摄摄像头 成功");
                break;
            }
        }
    }
    
    if(camera == nil){
        NSLog(@"获取前置摄像头 和 后摄摄像头 失败");
        return NO;
    }
    
    //3. 创建输入设备
    NSError *err = nil;
    AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:&err];
    if (err != nil) {
        NSLog(@"创建 视频 输入源失败 ");
        return NO;
    }
    self.videoInput = videoInput;
    
    //5. 添加输入输源
    [self.session beginConfiguration];
    if(![self.session canAddInput:videoInput]){
        [self.session commitConfiguration];
        NSLog(@"添加摄像输入源错误");
        return NO;
    }
    [self.session addInput:videoInput];
    [self.session commitConfiguration];
    return YES;
}

//1. 设置直播的视频输入输出 直接输出流
-(BOOL)setupLiveVideoOutput{
   
    //1. 创建输出设备 设置输出 代理
    AVCaptureVideoDataOutput *videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    [videoOutput setSampleBufferDelegate:self queue:self.outputQueue];
    self.videoOutput = videoOutput;
   
    //2. 添加输出源
    [self.session beginConfiguration];
    // 一般来说1s内至少有16张画面
    if(![self.session canAddOutput:videoOutput]){
        [self.session commitConfiguration];
        NSLog(@"添加视频输出源失败");
        return NO;
    }
    [self.session addOutput:videoOutput];
    [self.session commitConfiguration];
    return YES;
}

//4.创建movie的输出
-(BOOL)setupMovieFileOutput{

    
    AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc]init];
    
    AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    [connection setAutomaticallyAdjustsVideoMirroring:YES];
    
    [self.session beginConfiguration];
    if (![self.session canAddOutput:movieFileOutput]) {
        NSLog(@"添加video file output 失败");
        [self.session commitConfiguration];
        return NO;
    }
    [self.session addOutput:movieFileOutput];
    [self.session commitConfiguration];
    
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *videoPath = [path stringByAppendingPathComponent:@"/ac.mp4"];
    NSURL *url = [NSURL fileURLWithPath:videoPath];
    [movieFileOutput startRecordingToOutputFileURL:url recordingDelegate:self];
    
    self.movieFileOutput = movieFileOutput;
    return YES;
}


//2. 设置音频的输入输出
-(BOOL)setupAudioInputOutput{
    //1.获取音频设备
    AVCaptureDevice *audioDev = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    
    //2.创建音频输入源
    NSError *err = nil;
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDev error:&err];
    
    //3.创建音频输出源
    AVCaptureAudioDataOutput *audioOutput = [[AVCaptureAudioDataOutput alloc]init];
    [audioOutput setSampleBufferDelegate:self queue:self.outputQueue];
    
    //4.添加音频输入源
    [self.session beginConfiguration];
    if(![self.session  canAddInput:audioInput]){
        [self.session commitConfiguration];
        NSLog(@"添加音频输入源失败");
        return NO;
    }
    [self.session addInput:audioInput];
    
    //5.添加音频输出
    if(![self.session canAddOutput:audioOutput]){
        [self.session commitConfiguration];
        NSLog(@"添加音频输出源失败");
        return NO;
    }
    [self.session addOutput:audioOutput];
    [self.session commitConfiguration];
    return YES;
}

//3. 设置预览图层
-(void)setupPreviewLayer{
    AVCaptureVideoPreviewLayer *previewALayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    previewALayer.frame = self.parentLayer.bounds;
    [self.parentLayer insertSublayer:previewALayer atIndex:0];
}




#pragma mark- AVCaptureVideoDataOutputSampleBufferDelegate ,AVCaptureAudioDataOutputSampleBufferDelegate

// 视频输出源 和 音频输出源 回调函数
- (void)captureOutput:(AVCaptureOutput *)output
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection{
    
    // 采集到视频数据
    if([[self.videoOutput connectionWithMediaType:AVMediaTypeVideo] isEqual:connection]){
        
        NSLog(@"=============采集到一帧视频数据");
    }
    // 采集到音频数据
    else{
        NSLog(@"=============采集到一帧音频数据");
    }
    
}

// 当采集时发现丢帧了就会调用这个方法,但是通常丢的帧不会影响播放,所以通常这个代理方法会被我们忽略
- (void)captureOutput:(AVCaptureOutput *)output
  didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection{
    
    NSLog(@" 采集数据发现丢帧了, 不影响==========");
}


#pragma mark- AVCaptureFileOutputRecordingDelegate
// 通过代理监听开始写入文件和结束写入文件
- (void)captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections{
    
    NSLog(@"--------------开始录音了");
}
//- (void)captureOutput:(AVCaptureFileOutput *)output didPauseRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections NS_AVAILABLE_MAC(10_7){
//    NSLog(@"--------------暂停 录音了");
//
//}
//
//- (void)captureOutput:(AVCaptureFileOutput *)output didResumeRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections NS_AVAILABLE_MAC(10_7){
//    NSLog(@"--------------恢复 录音了");
//}
//
//- (void)captureOutput:(AVCaptureFileOutput *)output willFinishRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(nullable NSError *)error NS_AVAILABLE_MAC(10_7){
//    NSLog(@"--------------录音了 要完成了");
//}

- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(nullable NSError *)error{
    NSLog(@"--------------录音 完成了");
}
@end
