//
//  GPUDemoCell.m
//  GPUImageYRDemo
//
//  Created by yangrui on 2018/9/6.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import "GPUDemoCell.h"

@implementation GPUDemoCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.textLabel.font = [UIFont systemFontOfSize:25];
        self.detailTextLabel.font = [UIFont systemFontOfSize:20];
        self.detailTextLabel.textColor = [UIColor greenColor];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
}
@end
