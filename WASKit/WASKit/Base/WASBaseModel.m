//
//  WASBaseModel.m
//  WASKit
//
//  Created by admin on 17/2/24.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "WASBaseModel.h"
#import <objc/runtime.h>

@implementation WASBaseModel

- (void)encodeWithCoder:(NSCoder *)aCoder {
    unsigned int ivarCount;
    Ivar *ivars = class_copyIvarList([self class], &ivarCount);
    for (int i = 0; i < ivarCount; i++) {
        Ivar ivar = ivars[i];
        const char *ivarName = ivar_getName(ivar);
        NSString *key = [NSString stringWithCString:ivarName encoding:NSUTF8StringEncoding];
        id value = [self valueForKey:key];
        [aCoder encodeObject:value forKey:key];
    }
    free(ivars);
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        unsigned int ivarCount;
        Ivar *ivars = class_copyIvarList([self class], &ivarCount);
        for (int i = 0; i < ivarCount; i++) {
            Ivar ivar = ivars[i];
            const char *ivarName = ivar_getName(ivar);
            NSString *key = [NSString stringWithCString:ivarName encoding:NSUTF8StringEncoding];
            [self setValue:[aDecoder decodeObjectForKey:key] forKey:key];
        }
        free(ivars);
    }
    return self;
}

//重写description方法 方便调试
- (NSString *)description{
    //当然，如果你有兴趣知道出类名字和对象的内存地址，也可以像下面这样调用super的description方法
    //    NSString * desc = [super description];
    NSString * desc = @"\n";
    
    unsigned int outCount;
    //获取obj的属性数目
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    
    for (int i = 0; i < outCount; i ++) {
        objc_property_t property = properties[i];
        //获取property的C字符串
        const char * propName = property_getName(property);
        if (propName) {
            //获取NSString类型的property名字
            NSString    * prop = [NSString stringWithCString:propName encoding:[NSString defaultCStringEncoding]];
            //获取property对应的值
            id obj = [self valueForKey:prop];
            //将属性名和属性值拼接起来
            desc = [desc stringByAppendingFormat:@"%@ : %@;\n",prop,obj];
        }
    }
    
    free(properties);
    return desc;
}


@end
