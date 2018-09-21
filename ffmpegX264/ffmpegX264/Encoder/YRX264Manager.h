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
-(void)setFileSavePath:(NSString *)path;

/*
 * 设置X264
 * 0: 成功； －1: 失败
 * width: 视频宽度
 * height: 视频高度
 * bitrate: 视频码率，码率直接影响编码后视频画面的清晰度， 越大越清晰，但是为了便于保证编码后的数据量不至于过大，以及适应网络带宽传输，就需要合适的选择该值
 */
-(int)setX64ResourceWithVideoWidth:(int)width height:(int)height bitRate:(int)bitRate;

/*
 * 将CMSampleBufferRef格式的数据编码成h264并写入文件
 */
- (void)encoderToH264:(CMSampleBufferRef)sampleBuffer;

/*
 * 释放资源
 */
-(void)freeX264Resource;
@end
