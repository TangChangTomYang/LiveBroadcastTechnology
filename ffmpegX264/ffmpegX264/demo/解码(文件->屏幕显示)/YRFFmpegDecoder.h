//
//  YRFFmpegDecoder.h
//  ffmpegX264
//
//  Created by yangrui on 2018/9/27.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YRFFmpegDecoder : NSObject

@end


/** ffmpeg 解码的数据结构
 - AVFormatContext 封装格式上下文结构体,也是统领全局的结构体,保存了视频文件封装格式相关信息.
    - AVInputFormat  每种封装格式(例如: FLV, MKV, MP4, AVI )对应一个该结构体
    - AVStream  视频文件中每个视频(音频)流对应一个该结构体.AVStream是个数组,个数不确定一般实际应用只有2个,第0个是视频流,第1个是音频流.
        - AVCodecContext 编码器上下文结构体,保存了视频(音频)编解码相关信息. (和AVFormatContext 类似)
            -AVCodec 每种视频(音频)解码器(例如: H.264解码器)对应一个该结构体.
 
 - AVPacket 存储一帧解码前压缩编码视频(音频)数据.(比如: H.264码流)
 - AVFrame 存储一帧解码解码后视频(音频)数据.(比如: YUV数据,或PCM数据(音频))
 */


/** ffmpeg 数据结构分析
 - AVFormatContext 结构体中的主要变量
    iformat: 输入视频的封装格式(AVInputFormat)
    nb_streams: 输入视频的AVStream 个数
    streams: 输入视频的AVStream[] 数组
    duration: 输入视频的时长(单位,微秒)
    bit_rate: 输入视频的码率
 
 - AVInputFormat 结构体中的主要变量
    name: 封装格式的名称
    long_name: 封装格式的长名称
    extensions: 封装格式的扩展名
    id:封装格式ID
    一些封装格式处理的接口函数
 
 - AVStream 结构体主要变量
    id: 序号
    codec: 该流对应的AVCodecContext 结构体
    time_base: 该流的时基,时间的基础,时间的单位 (精确决定画面在那一刻显示,音频在那一刻播放)
    r_frame_rate: 该流的帧率(1秒有多少个画面)

 - AVCodecContext 结构体主要变量
    codec: 编解码器的AVCodec
    width height 图像的宽高(针对视频)
    pix_fmt: 像素格式(只针对视频)
    sample_rate: 采样率(只针对音频)
    channels: 声道数(只针对音频)
    sample_fmt: 采样格式(只针对音频)
 
 - AVCodec 结构体主要变量
    name:编解码器的名称
    long_name: 编解码器长名称
    type:编解码器的类型
    id: 编解码器ID
    一些便捷码的接口函数.
 
 - AVPacket 结构体的主要变量(装H.264)
    (关于pts和dts说明, 比如有帧是按1,2,3,4,5,6,7 存的,但是播的时候不一定是按1,2,3,4,5,6,7来播放,播放顺序和存储顺可能不一样,就是说有解码的顺序和显示的顺序)
    pts: 显示时间戳 (就是说 几分几秒放到屏幕上显示),最后的显示时间就是 = 时基*显示时间戳, 这就是pts的作用
    dts: 解码时间戳
    data: 压缩编码数据(H.264(视频), 音频码流)
    size: 压缩编码数据大小
    stream_index: 所属的AVStream
 
- AVFrame 结构体主要变量 (装YUV)
    data: 解码后的图像像素数据(音频 PCM)
    linesize : 对视频来说是图像中一行像素的大小,对音频来说是整个音频帧的大小
    width,height: 图像的宽度(只 视频)
    key_frame: 是否是关键帧(只 视频)
    pict_type: 帧类型(只 视频),例如: I,P,B帧
 */
