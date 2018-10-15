//
//  ViewController.m
//  YRFaceRecognitionDemo
//
//  Created by yangrui on 2018/10/12.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

#define GHColorRGBA(r,g,b,a)            [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)/255.0]
#define GHColor(r,g,b)                  GHColorRGBA(r,g,b,255.0)
#define GHRandomColor                   GHColor((arc4random_uniform(255)),(arc4random_uniform(255)),(arc4random_uniform(255)))

// 角度转弧度
#define DegreeToRadius(degree) (((degree)/(180.0f)) * (M_PI))
@interface ViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureMetadataOutputObjectsDelegate>
/** 捕捉会话*/
@property (nonatomic, weak) AVCaptureSession *captureSession;
/** 预览图层 */
@property (nonatomic, weak) AVCaptureVideoPreviewLayer *previewLayer;
/** 捕捉画面执行的线程队列 */
@property (nonatomic, strong) dispatch_queue_t captureQueue;

/** 识别到的人脸layer ID -> layer
 */
@property (nonatomic, strong) NSMutableDictionary *faceLayerDicM;
@end

@implementation ViewController


-(NSMutableDictionary *)faceLayerDicM{
    if (!_faceLayerDicM) {
        _faceLayerDicM = [NSMutableDictionary dictionary];
    }
    return _faceLayerDicM;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self startCapture:self.view];
}
- (void)startCapture:(UIView *)preview{
    
    // 1.创建捕捉会话
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPreset640x480;
    self.captureSession = session;
    
    // 2.添加摄像头输入 AVCaptureDeviceInput 并
    AVCaptureDevice *device = nil;
    NSArray<AVCaptureDevice *> *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for(AVCaptureDevice *dev in devices){
//        if (dev.position == AVCaptureDevicePositionFront) {
        if (dev.position == AVCaptureDevicePositionBack) {
            device = dev;
            break;
        }
    }
    NSError *error = nil;
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    [session addInput:input];
    
    // 3.添加输出设备
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    self.captureQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [output setSampleBufferDelegate:self queue:self.captureQueue];
    [session addOutput:output];
    
    //4. 设置视频捕捉方向
    // 注意:
    // 在设置 videoOrientation 一定实在将 output 添加到Session之后再设置
    AVCaptureConnection *connection = [output connectionWithMediaType:AVMediaTypeVideo];
    connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    //5. 添加人脸识别输出
    AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc]init];
    [session addOutput:metadataOutput];
    // 设置人脸识别的代理
    [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    // 注意:
    // 在获取availableMetadataObjectTypes 属性和设置metadataObjectTypes 属性一定要在将metadataOutput 添加到Session之后来设置, 否则会报错
    NSArray *types = metadataOutput.availableMetadataObjectTypes;
    for(AVMetadataObjectType type in types){
        // 查看可以获取到的metadataObject 有那些内类
        NSLog(@" availableType :  %@ ", type);
    }
    metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeFace];
    
    //6.添加预览图层
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    previewLayer.frame = preview.bounds;
    
    // 设置预览图层的拉伸方式
    // 这个属性是用来设置视频的拉伸情况的(当采集的分辨率和屏幕的分辨率不同时就可以看见效果)
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [preview.layer insertSublayer:previewLayer atIndex:0];
    self.previewLayer = previewLayer;
    
    //7. 开始摄像
    [self.captureSession startRunning];
    
}

- (void)stopCapture {
    [self.captureSession stopRunning];
    [self.previewLayer removeFromSuperlayer];
}

#pragma mark - 获取到数据
// 当采集到视频数据就会调用这个方法发把 CMSampleBufferRef 传出来
// 一个CMSampleBufferRef 就代表采集到的一帧画面
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    //NSLog(@"视频数据数据");
}

#pragma mark- AVCaptureMetadataOutputObjectsDelegate

/**
 1. 当检测到AVMetadataObject数据时会调用这个代理, AVMetadataObject 数据有很多种, 其中有一种就是人脸数据
 当然,我们在添加AVCaptureMetadataOutput 输出是设置了类型, 因此这个代理中只有人脸数据
 
 2. metadataObjects 是一个数组,包含各种类型的 AVMetadataObject.
 
 3. AVMetadataFaceObject 定义了多个描述检测到人脸的属性.其中,最重要的是人脸的边界(bounds), 它是CGRect类型的变量.
 他的坐标是基于设备标量坐标系,它的范围时摄像头原始朝向左上角(0,0)到右下角(1,1). 除了边界,AVMetadataFaceObject 还提供了检测到的人脸
 的倾斜角和偏转角.
 倾斜角(rollAngle) 表示人的头部向肩的方向侧倾角度, 偏转角(yawAngle) 表示人沿Y轴的旋转角
 3.AVMetadataFaceObject 还有一个重要的属性就是 faceID , 每个人脸AVFoundation 都会给faceID ,当人脸离开屏幕时,
 对应的人脸也会在回调方法中消失, 我们需要根据人脸ID 保存绘制的人脸矩形, 当人脸消失后, 我们需要将矩形去除
 */
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
 
    
    //检测到人脸数据是就会有值, 人脸检测失败就会置位空
    AVMetadataObject * metadata = metadataObjects.firstObject;
    if (metadata && metadata.type == AVMetadataObjectTypeFace) {
        
        AVMetadataFaceObject *face  = (AVMetadataFaceObject *)metadata;
        NSLog(@"倾斜角: %f, 偏转角:%f, bounds: %@",face.rollAngle,face.yawAngle ,NSStringFromCGRect(face.bounds) );
    }
    
    
    [self onDetectFaces:metadataObjects];
    
}





#pragma mark- 人脸Layer 方法


/**
 坐标变换:
 
 由于AVMetadataFaceObject 中的人脸的边界(bounds) 的坐标系是基于设备标量坐标系的,
 它的方位是摄像头原始朝向左上角(0,0)到右下角(1,1), 因此需要将它转换到我们的视图坐标系中.
 在转换的时候系统会考虑 orientation, mirroring, videoGravity等许多因素.
 在转换的时候,我们只需要使用AVCaptureVideoPreviewLayer 提供的
 - (nullable AVMetadataObject *)transformedMetadataObjectForMetadataObject:(AVMetadataObject *)metadataObject;
 方法.
 
 */
- (NSArray<AVMetadataFaceObject *>  *)previewLayer:(AVCaptureVideoPreviewLayer *)previewLayer transformedFaces:(NSArray<AVMetadataFaceObject *> *)faceArr{
    
    NSMutableArray *transformedFaceArrM = [NSMutableArray array];
    for (AVMetadataFaceObject *face in faceArr) {
        
        AVMetadataObject *transFace = [previewLayer transformedMetadataObjectForMetadataObject:face];
        [transformedFaceArrM addObject:transFace];
        
    }
    return transformedFaceArrM;
}

- (CALayer *)creatFaceLayer
{
    CALayer *layer = [CALayer layer];
    layer.backgroundColor = [GHRandomColor colorWithAlphaComponent:0.3] .CGColor;
    return layer;
}

- (CATransform3D)orientationTransform{
    
    NSDictionary *orientationDic = @{@(UIDeviceOrientationPortraitUpsideDown): @(M_PI),
                                     @(UIDeviceOrientationLandscapeRight):@(-M_PI/2.0),
                                     @(UIDeviceOrientationLandscapeLeft):@(M_PI/2.0)
      };
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientationDic[@(orientation)]) {
        return CATransform3DMakeRotation([orientationDic[@(orientation)] floatValue], 0.0f, 0.0f, 1.0f);
    }
    
    CGFloat angle  = 0.0f;
    return CATransform3DMakeRotation(angle, 0.0f, 0.0f, 1.0f);
}


/**透视投影*/
-(CATransform3D )perspectiveTransformMake:(CGFloat )distance{
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0 / distance;
    return transform;
}


- (CATransform3D)transformFromYawAngle:(CGFloat)angle
{
    CATransform3D t = CATransform3DMakeRotation(DegreeToRadius(angle), 0.0f, -1.0f, 0.0f);
    return CATransform3DConcat(t, [self orientationTransform]);
}




- (void)onDetectFaces:(NSArray<AVMetadataFaceObject *> *)faceObjs
{
    
    // 坐标变换
    NSArray<AVMetadataFaceObject *> *transFaces = [self previewLayer:self.previewLayer transformedFaces:faceObjs];
    
    NSMutableArray *originFaceIDs = [[self.faceLayerDicM allKeys] mutableCopy];
    
    for(NSNumber *originId in originFaceIDs){
        
        BOOL isContian = NO;
        for(AVMetadataFaceObject *metadata in  transFaces ){
            if(metadata.faceID == [originId integerValue]){
                isContian = YES;
                break;
            }
        }
        if(isContian == NO ){
            CALayer *layer = self.faceLayerDicM[originId];
            [layer removeFromSuperlayer];
            
            [self.faceLayerDicM removeObjectForKey:originId];
        }
    }
    
    for(AVMetadataFaceObject *faceObj in transFaces){
        CALayer *layer = self.faceLayerDicM[@(faceObj.faceID)];
        if(layer == nil){
            layer = [self creatFaceLayer];
            [self.previewLayer addSublayer:layer];
            self.faceLayerDicM[@(faceObj.faceID)] = layer;
        }
        
        
        layer.transform = [self perspectiveTransformMake:1000];
        layer.frame = faceObj.bounds;
        
        // 根据偏转角，对矩形进行旋转  (左右偏转)
        if (faceObj.hasRollAngle) {
            
            NSLog(@"rollAngle : ====%f=======", faceObj.rollAngle);
            CATransform3D t = CATransform3DMakeRotation(DegreeToRadius(faceObj.rollAngle), 0, 0, 1.0);
            layer.transform = CATransform3DConcat(layer.transform, t);
        }
        // 根据斜倾角，对矩形进行旋转变换 (前后仰视)
        if (faceObj.hasYawAngle) {
            CATransform3D t = [self transformFromYawAngle:faceObj.yawAngle];
            layer.transform = CATransform3DConcat(layer.transform, t);
        }
        
    }
    
    
}

@end





