//
//  ViewController.m
//  live
//
//  Created by yangrui on 2018/9/2.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import "ViewController.h"
#import "YRVideoRecordTool.h"

@interface ViewController ()

@end

@implementation ViewController
- (IBAction)startBtnClick:(id)sender {
//    [[YRVideoRecordTool shareVideoTool] setupLiveVideoWithParentLayer:self.view.layer];
//    [[YRVideoRecordTool shareVideoTool] startLive];
    
   
    [[YRVideoRecordTool shareVideoTool] setupRecordVideoWithParentLayer:self.view.layer];
    [[YRVideoRecordTool shareVideoTool] startRecord];
   
}


- (IBAction)rotateBtnClick:(id)sender {
    [[YRVideoRecordTool shareVideoTool] rotateCamera];
}

- (IBAction)stopBtnClick:(id)sender {
    
//    [[YRVideoRecordTool shareVideoTool] stopLive];
    [[YRVideoRecordTool shareVideoTool] stopRecord];
     [self.navigationController popViewControllerAnimated:YES];

}





@end




















