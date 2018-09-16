//
//  YRVideoEncoder.h
//  VideoToolBox
//
//  Created by yangrui on 2018/9/15.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VideoToolbox/VideoToolbox.h>

@interface YRVideoEncoder : NSObject

-(void)encodeSampleBuffer:(CMSampleBufferRef)sampleBuffer;

-(void)endCode;
@end
