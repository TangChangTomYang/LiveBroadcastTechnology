//
//  BlurViewController.m
//  GPUImageYRDemo
//
//  Created by yangrui on 2018/9/6.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import "BlurViewController.h"

@interface BlurViewController ()

@end

@implementation BlurViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/** 给一张照片,生成一张毛玻璃效果的图片*/
-(UIImage *)blurImage:(UIImage *)image{
    
    
    //1.创建一个用于处理单张图片的(类似于打开美图秀秀中的照片进行处理)
    //GPUImagePicture 继承自GPUImageOutput, 与filter的区别在于,filter 除了继承自GPUImageOutput 还遵守了GPUImageInput
    //因此 GPUImagePicture 是作为静态图像处理操作,一般作为响应链的源头
    GPUImagePicture *imagePicture = [[GPUImagePicture alloc] initWithImage:image];
    
    //2.创建毛玻璃滤镜
    GPUImageGaussianBlurFilter *blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
    //纹理大小
    blurFilter.texelSpacingMultiplier = 2.0;
    blurFilter.blurRadiusInPixels = 5.0;
    
    // 添加滤镜
    [imagePicture addTarget:blurFilter];
    
    //
    [blurFilter useNextFrameForImageCapture];
    [imagePicture processImage];
   return  [blurFilter imageFromCurrentFramebuffer];
}

@end
