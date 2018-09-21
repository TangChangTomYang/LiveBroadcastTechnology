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


@interface YRVideoCapture ()<AVCaptureVideoDataOutputSampleBufferDelegate>



/**编码对象*/
@property(nonatomic, strong)YRX264Manager *x264Mgr;

/**捕捉会话*/
@property(nonatomic, strong)AVCaptureSession *captureSession;

/**预览图层*/
@property(nonatomic, strong)CALayer *preLayer;

/**捕捉画面执行的线程队列*/
@property(nonatomic, strong)dispatch_queue_t  captureQueue;
@end

@implementation YRVideoCapture


-(void)startCapture:(UIView *)preView{
    
    
    //1. 初始化编码对象
    self.x264Mgr = [[YRX264Manager alloc]init];
    
    //2.获取沙盒路劲
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *file = [path stringByAppendingPathComponent:@"abc.h264"];
    
    //3.
    [self.x264Mgr setFileSavePath:file];
    
    //4. 特别注意高度和宽度
    [self.x264Mgr setX64ResourceWithVideoWidth:480 height:640 bitRate:1500000];
    
    //5. 创建捕捉会话
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPreset640x480; // 注意到没,这个宽高 x264 设置的宽高是反起的
   
    
    //6. 设置输入
    AVCaptureDevice *camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *err = nil;
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:&err];
    if(err){
        NSLog(@"创建 AVCaptureDeviceInput 失败: %@",err);
        return;
    }
    [session beginConfiguration];
    if(![session canAddInput:input]){
       
        [session commitConfiguration];
        NSLog(@"天剑 输入 失败");
        return;
    }
    [session addInput:input];
    [session commitConfiguration];
    
    
    //7. 添加剂输出
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc]init];
    self.captureQueue = dispatch_get_global_queue(0, 0);
    [output setSampleBufferDelegate:self queue:self.captureQueue];
    

    //8.
//    NSDictionary *settings =  [[NSDictionary alloc] initWithObjectsAndKeys:
//                              [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange],
//                              kCVPixelBufferPixelFormatTypeKey,
//                              nil];
//    output.videoSettings = settings;
    output.alwaysDiscardsLateVideoFrames = YES;
    [session addOutput:output];
    
    //9. 设置录制视频的方向
    AVCaptureConnection *connection = [output connectionWithMediaType:AVMediaTypeVideo];
    if ([connection isVideoOrientationSupported]) {
        NSLog(@"支持修改");
    }
    else{
        NSLog(@"不      支持修改");
    }
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    
    
    //10. 添加预览图层
    AVCaptureVideoPreviewLayer *preLayer = [[AVCaptureVideoPreviewLayer  alloc]init];
    preLayer.frame = preView.bounds;
    [preView.layer insertSublayer:preLayer above:0];
    self.preLayer = preLayer;
    
    
    //10. 开始捕捉
    [self.captureSession startRunning];
    self.captureSession = session;
}

- (void)stopCapture {
    [self.captureSession stopRunning];
    [self.preLayer removeFromSuperlayer];
    [self.x264Mgr freeX264Resource];
}


#pragma mark - 获取到数据
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    [self.x264Mgr encoderToH264:sampleBuffer];
}
@end



































