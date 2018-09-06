//
//  GPUImageFilterController.m
//  GPUImageYRDemo
//
//  Created by yangrui on 2018/9/6.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import "GPUImageFilterController.h"

@interface GPUImageFilterController ()

@end

@implementation GPUImageFilterController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *imgView1 = [[UIImageView alloc] initWithFrame:CGRectMake(40, 10, 150, 265)];
    imgView1.image = [self sepiaImage:[UIImage imageNamed:@"yinmuhuadao"]];
    [self.view addSubview:imgView1];
    
    UIImageView *imgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(230, 10, 150, 265)];
    imgView2.image = [self toonImage:[UIImage imageNamed:@"yinmuhuadao"]];
    [self.view addSubview:imgView2];
    
    UIImageView *imgView3 = [[UIImageView alloc] initWithFrame:CGRectMake(40, 310, 150, 265)];
    imgView3.image = [self sketchImage:[UIImage imageNamed:@"yinmuhuadao"]];
    [self.view addSubview:imgView3];
    
    UIImageView *imgView4 = [[UIImageView alloc] initWithFrame:CGRectMake(230,310, 150, 265)];
    imgView4.image = [self sepiaImage:[UIImage imageNamed:@"yinmuhuadao"]];
    [self.view addSubview:imgView4];
    
    UIImageView *imgView5 = [[UIImageView alloc] initWithFrame:CGRectMake(40, 570, 150, 265)];
    imgView5.image = [self embossImage:[UIImage imageNamed:@"yinmuhuadao"]];
    [self.view addSubview:imgView5];
    
}

// 褐色图片
-(UIImage *)sepiaImage:(UIImage *)image{
    GPUImageSepiaFilter *sepisFilter = [[GPUImageSepiaFilter alloc] init];
    return  [self processImage:image withFilter:sepisFilter];
}

// 卡通图片
-(UIImage *)toonImage:(UIImage *)image{
    GPUImageToonFilter *toonFilter = [[GPUImageToonFilter alloc] init];
    return  [self processImage:image withFilter:toonFilter];
}

// 素描图片
-(UIImage *)sketchImage:(UIImage *)image{
    GPUImageSketchFilter *sketchFilter = [[GPUImageSketchFilter alloc] init];
    return  [self processImage:image withFilter:sketchFilter];
}

// 浮雕图片
-(UIImage *)embossImage:(UIImage *)image{
    GPUImageEmbossFilter *embossFilter = [[GPUImageEmbossFilter alloc] init];
    return  [self processImage:image withFilter:embossFilter];
}

-(UIImage *)processImage:(UIImage *)imame withFilter:(GPUImageFilter *)filter{
    
    //1. 创建GPU图片
    GPUImagePicture *imagePicture = [[GPUImagePicture alloc]initWithImage:imame];
    
    //2. 添加需要处理的滤镜
    [imagePicture addTarget:filter];
    
    //3. 处理图片
    [filter useNextFrameForImageCapture];
    [imagePicture processImage];
    
    //4. 取出图片
    return  [filter imageFromCurrentFramebuffer];
    
}


@end
