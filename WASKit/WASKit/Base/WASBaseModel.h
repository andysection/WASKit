//
//  WASBaseModel.h
//  WASKit
//
//  Created by admin on 17/2/24.
//  Copyright © 2017年 admin. All rights reserved.
//  所有模型继承 需要归档解档只需要遵守NSCoding协议即可

#import <Foundation/Foundation.h>

@interface WASBaseModel : NSObject

- (void)encodeWithCoder:(NSCoder *)aCoder;

-(instancetype)initWithCoder:(NSCoder *)aDecoder;

@end
