//
//  AppDelegate.h
//  ffmpegX264
//
//  Created by yangrui on 2018/9/19.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end


/**
 int av_open_input_file(AVFormatContext **ic_ptr,
                     const char *filename,
                     AVInputFormat *fmt,
                     int buf_size,
                     AVFormatParameters *ap){
 
                         int url_fopen(ByteIOContext **s,
                                        const char *filename,
                                        int flags){

                                         url_open(URLContext **puc,
                                                 const char *filename,
                                                 int flags){

                                                 URLProtocol *up;
                                                 //根据filename确定up

                                                 url_open_protocol (URLContext **puc,
                                                                     struct URLProtocol *up,
                                                                     const char *filename,
                                                                     int flags) {

                                                                        //初始化URLContext对像，并通过 up->url_open()将I/O打开将I/O fd赋值给URLContext的priv_data对像

                                                 }

                                             }

                                         url_fdopen(ByteIOContext **s,
                                                    URLContext *h)  {

                                            //初始化ByteIOContext 对像

                                         }

                         }
 
 }
 */
