//
//  ViewController.m
//  VideoToolBox
//
//  Created by yangrui on 2018/9/15.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import "ViewController.h"
#import "YRVideoCapture.h"
@interface ViewController ()

@property(nonatomic, strong)YRVideoCapture *videoCapture;
@end

@implementation ViewController

-(YRVideoCapture *)videoCapture{
    if (!_videoCapture) {
        _videoCapture = [[YRVideoCapture alloc] init];
    }
    return _videoCapture;
}

- (IBAction)startCaptureClick:(id)sender {
    
    [self.videoCapture  startCapture:AVCaptureDevicePositionFront preView:self.view];
}

- (IBAction)stopCaptureClick:(id)sender {
    [self.videoCapture stopCapture];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

@end
