//
//  GPUImageDemoListController.m
//  GPUImageYRDemo
//
//  Created by yangrui on 2018/9/6.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import "GPUImageDemoListController.h"
#import "GPUDemoCell.h"

@interface GPUImageDemoListController ()

@property(nonatomic, strong)NSArray<NSDictionary *> *demoArr;

@end

@implementation GPUImageDemoListController


-(NSArray<NSDictionary *> *)demoArr{
    if (!_demoArr) {
        //GPUImagePicture 图片
        NSArray *pictureArr = @[ @{@"name":@"毛玻璃效果",@"filter":@"GPUImageGaussianBlurFilter",@"class":@"BlurViewController" }
                                ];
        
//        //GPUImageStillCamera 摄像头--照片拍照
//        NSArray *stillCameraArr = @[];
//        //GPUImageVideoCamera 摄像头--视频流 直播
//        NSArray *videoCameraArr = @[];
//        //GPUImageMovie 视频
//        NSArray *movieArr = @[];
        _demoArr = @[@{@"name":@"GPUImagePicture 图片", @"demos":pictureArr}];
    }
    return _demoArr;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self demoArr];
    
    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"GPU"];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.demoArr.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSDictionary *demoDic =  self.demoArr[section];
    return [demoDic[@"demos"] count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSDictionary *demoDic =  self.demoArr[section];
    return demoDic[@"name"] ;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 69;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GPUDemoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GPU"];
    if(!cell){
        cell = [[GPUDemoCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"GPU"];
    }
    NSDictionary *demoDic =  self.demoArr[indexPath.section];
    NSDictionary *dic = ((NSArray *)demoDic[@"demos"])[indexPath.row];
    cell.textLabel.text = dic[@"name"];
    cell.detailTextLabel.text = dic[@"filter"];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *demoDic =  self.demoArr[indexPath.section];
    NSDictionary *dic = ((NSArray *)demoDic[@"demos"])[indexPath.row];
    // @{@"name":@"毛玻璃效果",@"filter":@"GPUImageGaussianBlurFilter",@"class":@"BlurViewController" }
    NSString *clsStr = dic[@"class"];
    
    Class cls = NSClassFromString(clsStr);
    
    UIViewController *vc = (UIViewController *)[[cls alloc] init];
    vc.title = dic[@"name"];
    [self.navigationController pushViewController:vc animated:YES];
    
    
}
@end
