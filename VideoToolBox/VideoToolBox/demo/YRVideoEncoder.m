//
//  YRVideoEncoder.m
//  VideoToolBox
//
//  Created by yangrui on 2018/9/15.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import "YRVideoEncoder.h"

@interface YRVideoEncoder ()

/** 记录当前的帧数*/
@property(nonatomic, assign)NSInteger frameId;
/**编码会话*/
@property(nonatomic, assign)VTCompressionSessionRef compressSession;

@property(nonatomic, strong)NSFileHandle *fileHandle;
@end

@implementation YRVideoEncoder

-(instancetype)init{
    self = [super init];
    if (self) {
        //
        [self setupFileHandle];
        [self setupVideoSession];
        
    }
    return self;
}

-(void)setupFileHandle{
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *file = [path stringByAppendingPathComponent:@"abc.h264"];

    //1. 如果原来有文件 就删除原来的文件
    if([[NSFileManager defaultManager] fileExistsAtPath:file]){
       [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    }
    [[NSFileManager defaultManager] createFileAtPath:file contents:nil attributes:nil];

    //2.
    self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:file];
    
    
    
    
 
    
}




-(void)setupVideoSession{
    
    //1. 用于记录当前是第几帧数据(画面的帧数非常的多)
    self.frameId = 0;
    
    //2. 录制视频的宽度和高度
    int width = [UIScreen mainScreen].bounds.size.width;
    int height = [UIScreen mainScreen].bounds.size.height;
    
    //3.创建compressSession 对像,改该对象用于对画面进行编码
    // kCMVideoCodecType_H264 表示使用H264进行编码
    // didCompressH2264 当一次编码结束,会在该函数回调,可以在该函数中将数据写入文件中
    VTCompressionSessionCreate(NULL,
                               width,
                               height,
                               kCMVideoCodecType_H264,
                               NULL,
                               NULL,
                               NULL,
                               didCompressH2264,
                               (__bridge  void *)(self),
                               &_compressSession);
    
    //4. 设置实时编码输出(直播必然是实时输出,否则会有延迟)
    VTSessionSetProperty(self.compressSession, kVTCompressionPropertyKey_RealTime,kCFBooleanTrue );
    
    //5. 设置期望帧率(每秒是多少帧,如果帧率过低,会造成画面卡顿)
    int fps = 30;
    CFNumberRef fpsNum = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &fps);
    VTSessionSetProperty(self.compressSession, kVTCompressionPropertyKey_ExpectedFrameRate, fpsNum);
    
    //6.设置码率(码率: 编码效率,码率越高则画面越清晰,如果码率较低会引起马赛克)
    //码率高有利于还原,原始画面,但是不利于传输
    int bitRate = 800*1024;
    CFNumberRef bitRateRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &bitRate);
    VTSessionSetProperty(self.compressSession, kVTCompressionPropertyKey_AverageBitRate, bitRateRef);
    NSArray *limit = @[@(bitRate * 1.5/8),@(1)];
    VTSessionSetProperty(self.compressSession, kVTCompressionPropertyKey_DataRateLimits, (__bridge CFArrayRef)limit);
    
    //7.设置关键帧(GOPsize)间隔
    int frameInterval = 30;
    
    CFNumberRef frameIntervalRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &frameInterval);
    VTSessionSetProperty(self.compressSession, kVTCompressionPropertyKey_MaxKeyFrameInterval, frameIntervalRef);
    // 8.基本设置结束, 准备进行编码
    VTCompressionSessionPrepareToEncodeFrames(self.compressSession);
    
}


/** 编码完成回调函数*/
void didCompressH2264(void *outputCallbackRefCon,
                      void *sourceFrameRefCon,
                      OSStatus status,
                      VTEncodeInfoFlags infoFlags,
                      CMSampleBufferRef sampleBuffer){
    
    //1. 判断状态是否等于没有错误
    if (status != noErr) {
        return;
    }
    
    //2. 根据传入的参数获取duixinag
    YRVideoEncoder *encoder = (__bridge YRVideoEncoder *)outputCallbackRefCon;
    
    //3. 判断是否是关键帧(I帧)
    CFArrayRef attachmentsArrRef = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, true);
    CFDictionaryRef dicRef = CFArrayGetValueAtIndex(attachmentsArrRef, 0);
    bool isKeyFrame = !CFDictionaryContainsKey(dicRef, kCMSampleAttachmentKey_NotSync);
    
    
    //判断当前是否为关键帧
    //获取sps & pps 数据
    if(isKeyFrame){
        
        // 获取编码后的信息(存储于CMFormatDescriptionRef 中)
        CMFormatDescriptionRef format = CMSampleBufferGetFormatDescription(sampleBuffer);
        
        //获取sps信息
        size_t sparameterSetSize,sparameterSetCount;
        const uint8_t *sparameterSet;
        CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 0, &sparameterSet, &sparameterSetSize, &sparameterSetCount, 0);
        
        //获取pps信息
        size_t pparameterSetSize, ppatameterSetCount;
        const uint8_t *pparameterSet;
        CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 1, &pparameterSet, &pparameterSetSize, &ppatameterSetCount, 0);
        
        //将sps & pps 装换成data ,以便写入文件
        NSData *spsData = [NSData dataWithBytes:sparameterSet length:sparameterSetSize];
        NSData *ppsData = [NSData dataWithBytes:pparameterSet length:pparameterSetSize];
        
        //写入文件
        [encoder gotSpsPps:spsData pps:ppsData];
    }
    else{
        
        //获取数据块
        CMBlockBufferRef dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
        size_t length,totalLength;
        char *dataPointer;
        OSStatus statusCodeRet = CMBlockBufferGetDataPointer(dataBuffer, 0, &length, &totalLength, &dataPointer);
        
        if (statusCodeRet == noErr) {
            
            size_t bufferOffset = 0;
            // 返回NALU 数据的前4个字节不是0001 的startCode ,而是大端模式帧长度length
            static const int AVCCHeaderLength  = 4;
            
            //循环获取NALU 数据
            while(bufferOffset < totalLength - AVCCHeaderLength){
                uint32_t NALULength = 0;
                
                //read the NAL Unit Length
                memcpy(&NALULength, dataPointer + bufferOffset, AVCCHeaderLength);
                
                //从大端转系统端
                NALULength = CFSwapInt32BigToHost(NALULength);
                
                NSData *data = [[NSData alloc]initWithBytes:(dataPointer + bufferOffset + AVCCHeaderLength) length:NALULength];
                [encoder gotEncodedDdata:data isKeyFrame:isKeyFrame];
                
                // 移动到下一个块. 转成NALU单元
                // Move to the next NAL unit in the block buffer
                bufferOffset += AVCCHeaderLength + NALULength;
                
            }
        }
        
    }
}


-(void)gotSpsPps:(NSData *)sps pps:(NSData *)pps{
    
    if(self.fileHandle != NULL){
        //1. 拼接NALU的Header
        const char bytes[] = "\x00\x00\x00\x01";
        size_t length = (sizeof bytes) - 1;
        NSData *byteHeader = [NSData dataWithBytes:bytes length:length];
        //2. 将NALU的头和NALU的体写入文件
        [self.fileHandle writeData:byteHeader];
        [self.fileHandle writeData:sps];
        [self.fileHandle writeData:byteHeader];
        [self.fileHandle writeData:pps];
    }
  
    
}

-(void)gotEncodedDdata:(NSData *)encodedData isKeyFrame:(BOOL)isKeyFrame{
    
    NSLog(@"gotEncodedDdata length: %ld ", encodedData.length);
    
    if(self.fileHandle != NULL){
        //1. 拼接NALU的Header
        const char bytes[] = "\x00\x00\x00\x01";
        size_t length = (sizeof bytes) - 1;
        NSData *byteHeader = [NSData dataWithBytes:bytes length:length];
        
        [self.fileHandle writeData:byteHeader];
        [self.fileHandle writeData:encodedData];
    }
    
}



#pragma mark- 说明文字
-(void)encodeSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    
    //1. 将sampleBuffer 转换成imageBuffer
    CVImageBufferRef imageBuffer = (CVImageBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    
    //2. 根据当前的帧数.创建CMTime 的时间
    CMTime presentationTimeStamp = CMTimeMake(self.frameId++, 1000); //1000 表示可以把时间精确到1/1000 秒, 因为时间上稍微有点不同步人耳听起来不好听
    VTEncodeInfoFlags flags;
    //3. 开始编码该帧数据
    
    OSStatus statusCode =  VTCompressionSessionEncodeFrame(self.compressSession,
                                    imageBuffer,
                                    presentationTimeStamp,
                                    kCMTimeInvalid,
                                    NULL,
                                    (__bridge void *)self,
                                    &flags);
    
    if (statusCode == noErr) {
        NSLog(@"H264: VTCompressionSessionEncodeFrame Success");
    }
    
}


-(void)endEncode{
   
    VTCompressionSessionCompleteFrames(self.compressSession, kCMTimeInvalid);
    VTCompressionSessionInvalidate(self.compressSession);
    CFRelease(self.compressSession);
    self.compressSession  = NULL;
    
    
    
}














@end
