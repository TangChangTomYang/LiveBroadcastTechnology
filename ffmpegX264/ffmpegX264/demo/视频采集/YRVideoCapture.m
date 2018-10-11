//
//  YRVideoCapture.m
//  ffmpegX264
//
//  Created by yangrui on 2018/9/19.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import "YRVideoCapture.h"
#import "YRX264Manager.h"
#import <AVFoundation/AVFoundation.h>

@interface YRVideoCapture () <AVCaptureVideoDataOutputSampleBufferDelegate>

/** 编码对象 */
@property (nonatomic, strong) YRX264Manager *encoder;

/** 捕捉会话*/
@property (nonatomic, weak) AVCaptureSession *captureSession;

/** 预览图层 */
@property (nonatomic, weak) AVCaptureVideoPreviewLayer *previewLayer;

/** 捕捉画面执行的线程队列 */
@property (nonatomic, strong) dispatch_queue_t captureQueue;

@end

@implementation YRVideoCapture

- (void)startCapture:(UIView *)preview
{
    
    // 0.初始化编码对象
    self.encoder = [[YRX264Manager alloc] init];
    
    // 1.获取沙盒路径
    NSString *file = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"abc.h264"];
    
    // 2.开始编码
    [self.encoder setFileSavedPath:file];
    
   
    
    // 1.创建捕捉会话
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    // 注意这个尺寸仅仅是用来说明采集的视频的尺寸的宽高是那种
    // 比如 640x480 描述的只是一个尺寸,但并不确定640一定表示是宽或者480一定表示是高
    // 这个是用来设置采集画面的分辨率的
    session.sessionPreset = AVCaptureSessionPreset640x480;
    
    self.captureSession = session;
    
    // 2.设置输入设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    [session addInput:input];
    
    
    
    
    // 3.添加输出设备
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    self.captureQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [output setSampleBufferDelegate:self queue:self.captureQueue];
    //
//    @{(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey: [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]};
//    NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
//                              [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange],
//                              kCVPixelBufferPixelFormatTypeKey,
//                              nil];
    
    // 设置像素的格式为YUV420p(即像素的颜色空间是YUV420p)  U分量个数 = V分量个数 = (1/4) * Y分量个数
    // 软编码是这个像素的颜色空间是必须要设置的, 因为只有确定了采集的颜色空间,取像素时也需要使用相同的格式来取才正确
    NSDictionary *settings = @{(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};

    output.videoSettings = settings;
    
    // 是否允许丢弃一些来不及处理的帧
    output.alwaysDiscardsLateVideoFrames = YES;
    
    // 设置录制视频的方向
    [session addOutput:output];
    //注意(1): [connection setVideoOrientation:AVCaptureVideoOrientationPortrait]; 一定要在 [session addOutput:output]; 之后来设置
    AVCaptureConnection *connection = [output connectionWithMediaType:AVMediaTypeVideo];
    
    if ([connection isVideoOrientationSupported]) {
        NSLog(@"支持修改");
    } else {
        NSLog(@"不知修改");
    }
   connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    
    // 特别特别注意: 宽度&高度
    // 这个 宽度和高度直接决定软编码时数据的获取方式很重要
    // 通过sessionPreset设置的值来确定尺寸大小
    // 具体的宽高 依据 connection.videoOrientation 和 session.sessionPreset 这两个参数决定
    [self.encoder setX264ResourceWithVideoWidth:480 height:640 bitrate:1500000];
    
    
    
    // 4.添加预览图层
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    previewLayer.frame = preview.bounds;
    [preview.layer insertSublayer:previewLayer atIndex:0];
    self.previewLayer = previewLayer;
    
    
    // 5.开始捕捉
    [self.captureSession startRunning];
}

- (void)stopCapture {
    [self.captureSession stopRunning];
    [self.previewLayer removeFromSuperlayer];
    [self.encoder freeX264Resource];
}

#pragma mark - 获取到数据
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    // 拿到采集的数据
    [self.encoder encoderToH264:sampleBuffer];
}

@end
































