//
//  YRX264Manager.h
//  ffmpegX264
//
//  Created by yangrui on 2018/9/19.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

@interface YRX264Manager : NSObject

/*
 * 设置编码后文件的保存路径
 */
- (void)setFileSavedPath:(NSString *)path;

/*
 * 设置X264
 * 0: 成功； －1: 失败
 * width: 视频宽度
 * height: 视频高度
 * bitrate: 视频码率，码率直接影响编码后视频画面的清晰度， 越大越清晰，但是为了便于保证编码后的数据量不至于过大，以及适应网络带宽传输，就需要合适的选择该值
 */
- (int)setX264ResourceWithVideoWidth:(int)width height:(int)height bitrate:(int)bitrate;

/*
 * 将CMSampleBufferRef格式的数据编码成h264并写入文件
 */
- (void)encoderToH264:(CMSampleBufferRef)sampleBuffer;

/*
 * 释放资源
 */
- (void)freeX264Resource;


@end


// ffmpeg 中重要的结构体含义整理
/** AVFrame
 AVFrame 结构体一般用于存储原始数据(即非压缩数据,例如: 对于视频来说是YUV \RGB,对于音频来说是PCM),此外还包含一些相关的信息,
 比如说: 解码的时候存储的宏块类型表\QP表\运动矢量表等数据.编码的时候也存储了相关的数据,因此在使用ffmpeg 进行码流分析的时候AVFRame是一个很
 重要的数据
 参数1:
 参数2:
 参数3:
 参数4:
 */
