//
//  YRVideoRecordTool.h
//  live
//
//  Created by yangrui on 2018/9/3.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YRVideoRecordTool : NSObject



+(instancetype)shareVideoTool;


/** 开始直播*/
-(void)startLive;
/** 停止直播*/
-(void)stopLive;

/** 开始 录屏*/
-(void)startRecord;
/** 停止 录屏*/
-(void)stopRecord;


/** 切换摄像头 */
-(BOOL)rotateCamera;


-(BOOL)setupLiveVideoWithParentLayer:(CALayer *)parentLayer;

-(BOOL)setupRecordVideoWithParentLayer:(CALayer *)parentLayer;

@end


