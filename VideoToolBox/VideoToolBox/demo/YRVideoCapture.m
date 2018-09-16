//
//  YRVideoCapture.m
//  VideoToolBox
//
//  Created by yangrui on 2018/9/15.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import "YRVideoCapture.h"


@interface YRVideoCapture ()<AVCaptureAudioDataOutputSampleBufferDelegate>
/**编码对象*/
@property(nonatomic, strong)YRVideoEncoder *encoder;
/**捕捉会话*/
@property(nonatomic, strong)AVCaptureSession *captureSession;
/** 预览图层 */
@property(nonatomic, strong)AVCaptureVideoPreviewLayer *preViewlayer;
/**捕捉画面执行的线程队列*/
@property(nonatomic, strong)dispatch_queue_t captureQueue;


@end

@implementation YRVideoCapture


-(BOOL)startCapture:(AVCaptureDevicePosition)position  preView:(UIView *)preView {
    if (AVCaptureDevicePositionBack != position && AVCaptureDevicePositionFront != position  ) {
        NSLog(@"只能是前摄或者后摄");
        return NO ;
    }
    
    //1. 初识化编码对象
    self.encoder = [[YRVideoEncoder alloc] init];
    
    //2. 创建捕捉会话
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPreset1280x720;
//    self.captureSession = session;
    
    //3. 设置输入设备
    NSArray<AVCaptureDevice *> *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *camera = nil;
    for (AVCaptureDevice *dev in devices) {
        if (dev.position == position) {
            camera = camera;
            break;
        }
    }
    NSError *err = nil;
    
    camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:&err];
//    if (err != nil) {
//        NSLog(@"添加摄像头输入源错误: %@",err);
//        return NO;
//    }
    
    [session beginConfiguration];
    if (![session canAddInput:input]) {
        [session commitConfiguration];
        return NO;
    }
    [session addInput:input];
   
    
    //4.添加输出设备
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc]init];
    self.captureQueue = dispatch_get_global_queue(0, 0  );
    [output setSampleBufferDelegate:self queue:self.captureQueue];
    if (![session canAddOutput:output]) {
        [session commitConfiguration];
        return NO;
    }
    [session addOutput:output];
    [session commitConfiguration];
    
    
    //5. 设置录制视频的方向
    AVCaptureConnection *connection = [output connectionWithMediaType:AVMediaTypeVideo];
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    
    //6. 添加预览图层
    AVCaptureVideoPreviewLayer *preViewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    preViewLayer.frame = preView.bounds;
    [preView.layer insertSublayer:preViewLayer atIndex:0];
    self.preViewlayer = preViewLayer;
    
    [session startRunning];
    self.captureSession = session;
    
    return YES;
}


-(void)stopCapture{
    [self.captureSession stopRunning];
    [self.preViewlayer removeFromSuperlayer];
    [self.encoder endCode];
}

#pragma mark- AVCaptureAudioDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection{
    
    NSLog(@"--------encodeSampleBuffer");
    [self.encoder encodeSampleBuffer:sampleBuffer];
    
}



@end























