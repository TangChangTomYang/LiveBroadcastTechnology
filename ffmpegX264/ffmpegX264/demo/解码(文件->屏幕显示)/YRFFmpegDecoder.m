//
//  YRFFmpegDecoder.m
//  ffmpegX264
//
//  Created by yangrui on 2018/9/27.
//  Copyright © 2018年 yangrui. All rights reserved.
//
#import "YRFFmpegDecoder.h"

#ifdef __cplusplus
extern "C" {
#endif
#include "libavcodec/avcodec.h"
#include "libavformat/avformat.h"
#include "libswscale/swscale.h"
#ifdef __cplusplus
};
#endif


@implementation YRFFmpegDecoder{
    AVFormatContext    *pFormatCtx;
    int                i, videoindex;
    AVCodecContext    *pCodecCtx;
    AVCodec            *pCodec;
    AVFrame    *pFrame,*pFrameYUV;
    uint8_t *out_buffer;
    AVPacket *packet;
    int y_size;
    int ret, got_picture;
    struct SwsContext *img_convert_ctx;
   
   
}

-(int)deCoder{
    // 视频文件路径
    char filepath[]="Titanic.ts";
    
    int frame_cnt;
    
    //1. 注册所欲的组件
    av_register_all();
    
    // 初始化网络
    avformat_network_init();
    // 创建封装格式上下文
    pFormatCtx = avformat_alloc_context();
    
    //2. 打开输入视频(音频)文件
    if(avformat_open_input(&pFormatCtx,filepath,NULL,NULL)!=0){
        printf("Couldn't open input stream.\n");
        return -1;
    }
    
    // 查看视频(音频)流(AVStream)信息
    if(avformat_find_stream_info(pFormatCtx,NULL)<0){
        printf("Couldn't find stream information.\n");
        return -1;
    }
    
    // 获取视频流的序号
    videoindex=-1;
    // AVFormatContext(封装格式上下文)中nb_streams表示, AVFormatContext中stream的个数
    // stream 是码流的数组, 一般只有2个,stream[0] 表示视频流, stream[1] 是音频流
    for(i=0; i<pFormatCtx->nb_streams; i++){
        if(pFormatCtx->streams[i]->codec->codec_type==AVMEDIA_TYPE_VIDEO){
            videoindex=i;
            break;
        }
    }
    if(videoindex==-1){
        printf("Didn't find a video stream.\n");
        return -1;
    }
    
    //获取编解码器上下文
    pCodecCtx=pFormatCtx->streams[videoindex]->codec;
    //4. 通过编解码器id 找到便捷码器
    pCodec=avcodec_find_decoder(pCodecCtx->codec_id);
    if(pCodec==NULL){
        printf("Codec not found.\n");
        return -1;
    }
    
    //5. 打开编解码器
    if(avcodec_open2(pCodecCtx, pCodec,NULL)<0){
        printf("Could not open codec.\n");
        return -1;
    }
    
    // 创建一个AVFrame (AVFrame里面存的 YUV数据或者PCM数据)
    pFrame=av_frame_alloc();
    pFrameYUV=av_frame_alloc();
    int  avPicSize = avpicture_get_size(PIX_FMT_YUV420P,
                                        pCodecCtx->width,
                                        pCodecCtx->height);
    out_buffer=(uint8_t *)av_malloc(avPicSize);
    avpicture_fill((AVPicture *)pFrameYUV,
                   out_buffer,
                   PIX_FMT_YUV420P,
                   pCodecCtx->width,
                   pCodecCtx->height);
    packet=(AVPacket *)av_malloc(sizeof(AVPacket));
    //Output Info-----------------------------
    printf("--------------- File Information ----------------\n");
    av_dump_format(pFormatCtx,0,filepath,0);
    printf("-------------------------------------------------\n");
    img_convert_ctx = sws_getContext(pCodecCtx->width,
                                     pCodecCtx->height,
                                     pCodecCtx->pix_fmt,
                                     pCodecCtx->width,
                                     pCodecCtx->height,
                                     PIX_FMT_YUV420P,
                                     SWS_BICUBIC,
                                     NULL,
                                     NULL,
                                     NULL);
    
    // 将.264的码流数据写入文件(testOutput.264)
    FILE *fp_264 = fopen("/Users/yang/Desktop/outputx264/testOutput.264", "wb+");
    
    // 将YUV数据写入文件(testOutput.YUV)
    FILE *fp_YUV = fopen("/Users/yang/Desktop/outputx264/testOutput.YUV", "wb+");
    
    
    // 帧的个数
    frame_cnt=0;
    // 读取帧 (视频帧或者音频帧)
    while(av_read_frame(pFormatCtx, packet)>=0){
        // 判断是否是视频帧
        if(packet->stream_index==videoindex){ // 是视频
           
            // 将视频码流写入文件, packet 中的data就是 H.264的码流
            // 1 表示每次写一个, 一个写packet->size 次
            fwrite(packet->data, 1, packet->size, fp_264);
            
            
            ret = avcodec_decode_video2(pCodecCtx,
                                        pFrame,
                                        &got_picture,
                                        packet);
            
            if(ret < 0){
                printf("Decode Error.\n");
                return -1;
            }
            
            if(got_picture){
                // 说明: 一般解码出来的YUV数据比实际的尺寸大,  在右边有个空白区域(有黑边 ),在写入文件时需要把右边的黑边裁掉
                // 本来是输出的YUV Data数据在pframe中, 因为我们要经过了sws_scale函数裁掉黑边, 最后YUV data 转存在pframeYUV中了
                sws_scale(img_convert_ctx,
                          (const uint8_t* const*)pFrame->data,  // 有黑边的frame
                          pFrame->linesize,
                          0,
                          pCodecCtx->height,
                          pFrameYUV->data,  // 裁掉后存在frameYUV中
                          pFrameYUV->linesize);
                
                printf("Decoded frame index: %d\n",frame_cnt);
               
                
                // 注意pFrame 中的data是一个数据,data[0]存的是Y数据(亮度数据,即黑白数据), data[1]存的是U数据,data[2]存的是V数据
                // YUV中,UV数据量只有Y数据量的四分之一,在写入文件时需要注意
                int YdataCount = pCodecCtx->width * pCodecCtx->height; // Y数据量(1个Y数据就是一个屏幕上所有的点,因此数据量=屏幕的宽*屏幕的高)
                fwrite(pFrameYUV->data[0], 1,YdataCount, fp_YUV); // Y分量
                fwrite(pFrameYUV->data[1], 1,YdataCount / 4, fp_YUV); // U分量 是Y的 1/4
                fwrite(pFrameYUV->data[2], 1,YdataCount / 4, fp_YUV); // V分量 是Y的 1/4
                // 420p 宽高都是Y的一半
                
                frame_cnt++;
                
            }
        }
        av_free_packet(packet);
    }
    // 关闭写入文件
    fclose(fp_264);
    
    sws_freeContext(img_convert_ctx);
    
    av_frame_free(&pFrameYUV);
    av_frame_free(&pFrame);
    avcodec_close(pCodecCtx);
    avformat_close_input(&pFormatCtx);
    
    return 0;
}

@end
