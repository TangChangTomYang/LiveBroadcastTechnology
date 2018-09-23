//
//  ViewController.m
//  ffmpegX264
//
//  Created by yangrui on 2018/9/19.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import "ViewController.h"
#import "YRVideoCapture.h"

@interface ViewController ()

/** 视频捕捉对象 */
@property (nonatomic, strong) YRVideoCapture *videoCapture;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)startCapture {
    [self.videoCapture startCapture:self.view];
}

- (IBAction)stopCapture {
    [self.videoCapture stopCapture];
}

- (YRVideoCapture *)videoCapture {
    if (_videoCapture == nil) {
        _videoCapture = [[YRVideoCapture alloc] init];
    }
    
    return _videoCapture;
}

@end

