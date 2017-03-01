//
//  WASProgressView.h
//  LilyForParent
//
//  Created by admin on 17/2/21.
//  Copyright © 2017年 Lily. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WASProgressView : UIView

/** 设置进度*/
@property (nonatomic) CGFloat progress;

/**进度条颜色*/
@property (nonatomic, strong) UIColor *progressBarColor;

/**进度条背景色*/
@property (nonatomic, strong) UIColor *progressBgColor;

/**字体内容**/
@property (nonatomic, copy) NSString *text;

/**字体**/
@property (nonatomic, strong) UIFont *font;

/*字体颜色*/
@property (nonatomic, strong) UIColor *textColor;
@end
