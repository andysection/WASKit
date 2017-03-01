//
//  WASProgressView.m
//  LilyForParent
//
//  Created by admin on 17/2/21.
//  Copyright © 2017年 Lily. All rights reserved.
//

#import "WASProgressView.h"

@implementation WASProgressView

{
    UILabel *_label;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
//        self.backgroundColor = [UIColor clearColor];
        self.progressBarColor = [UIColor orangeColor];
        self.progressBgColor = [UIColor colorWithRed:240/255.0 green:220/255.0 blue:200/255.0 alpha:1];
        UILabel *label = [[UILabel alloc] init];
        [label sizeToFit];
        [self addSubview:label];
//        label.layer.masksToBounds = YES;
        label.backgroundColor = [UIColor darkGrayColor];
        _label = label;
    }
    return self;
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)setText:(NSString *)text{
    _text = text;
    _label.text = text;
    [_label sizeToFit];
}

- (void)setFont:(UIFont *)font{
    _font = font;
    _label.font = font;
    [self setNeedsDisplay];
}

- (void)setTextColor:(UIColor *)textColor{
    _textColor = textColor;
    _label.textColor = textColor;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawProgressBackground:context inRect:rect];
    
    if (self.progress > 0) {
        CGRect progressRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width * self.progress, rect.size.height);
        [self drawProgress:context withFrame: progressRect];
        _label.center = CGPointMake(progressRect.size.width*0.5, progressRect.size.height*0.5);
    }
}

- (void)drawProgressBackground:(CGContextRef)context inRect:(CGRect)rect {
    CGContextSaveGState(context);
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:rect.size.height/2];
    CGContextSetFillColorWithColor(context, self.progressBgColor.CGColor);
    [roundedRect fill];
    
    UIBezierPath *roundedClipPath = [UIBezierPath bezierPathWithRect:rect];
    [roundedClipPath appendPath:roundedRect];
    [roundedRect addClip];
}

- (void)drawProgress:(CGContextRef)context withFrame:(CGRect)frame {
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:frame.size.height/2];
    
    CGContextSetFillColorWithColor(context, self.progressBarColor.CGColor);
    [roundedRect fill];
}


@end
