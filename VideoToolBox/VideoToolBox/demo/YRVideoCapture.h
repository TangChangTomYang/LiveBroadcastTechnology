//
//  YRVideoCapture.h
//  VideoToolBox
//
//  Created by yangrui on 2018/9/15.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "YRVideoEncoder.h"

@interface YRVideoCapture : NSObject


-(BOOL)startCapture:(AVCaptureDevicePosition)position  preView:(UIView *)preView ;
-(void)stopCapture;

@end
