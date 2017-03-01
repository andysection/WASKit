//
//  WASTableViewCell.m
//  WASKit
//
//  Created by admin on 17/2/25.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "WASTableViewCell.h"
#import "WASProgressView.h"

@implementation WASTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)initUI{
    self.contentView.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView =[UIImageView new];
    imageView.image = [UIImage imageNamed:@"menu"];
    [self.contentView addSubview:imageView];
    [imageView sizeToFit];
    imageView.frame  = CGRectMake(20, 5, 50, 50);
//    imageView.backgroundColor = self.contentView.backgroundColor;
    
    WASProgressView *progressView = [[WASProgressView alloc] initWithFrame:CGRectMake(20, 60, 200, 50)];
    progressView.progressBarColor = [UIColor grayColor];
    progressView.progressBgColor = [UIColor darkGrayColor];
    progressView.text = @"10/10";
    progressView.progress = 0.5;
//        progressView.layer.shouldRasterize =YES;
    [self.contentView addSubview:progressView];
    progressView.backgroundColor = self.contentView.backgroundColor;
    
    UIView *v = [UIView new];
    v.frame = CGRectMake(20, 120, 50 , 50);
//    v.backgroundColor = [UIColor blueColor];
//    v.alpha = 0.7;
//    v.layer.cornerRadius = 10;
//    v.layer.masksToBounds = YES;
    [self.contentView addSubview:v];
    
//    v.layer.shadowPath = CGPathCreateWithRect(CGRectMake(20, 120, 60, 60), NULL);
    CALayer *layer = v.layer;
    layer.shadowOffset = CGSizeMake(5, 5);
    layer.shadowColor = (__bridge CGColorRef _Nullable)([UIColor blackColor]);
    layer.shadowOpacity = 1;
    layer.shadowRadius = 4;
    

}

@end
