//
//  WASDBManager.h
//  WASKit
//
//  Created by admin on 17/2/28.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <sqlite3.h>

/*
 
 数据对象约束
 
 class name 为表名
 key 字段名 必须为 keyid sting；
 非数据库字段 已 _ 开头 如 _type
 
 字段类型 int NSString
 
 
 */

#define NKDBO_DBNAME    @"northking.sqlite"

@interface WASDBManager : NSObject
{
    
    sqlite3 *m_db;
    
}

/**
 *  单例初始化
 *
 *  @return 返回实例
 */
+(WASDBManager*)share;
/**
 *  通过Model类名+Sql语句 获取数据库中的数据
 *
 *  @param classz Model类名   例如 [NKModel class]
 *  @param sql    通过类的成员属性+查询条件(是基于Where后面的条件) 例如: name = @"视频1";   name 是Model类的成员属性
 *
 *  @return 返回数据数组
 */
-(NSArray*)listByClass:(Class)classz sql:(NSString*)sql;
/**
 *  在数据库中初始化一些表（一般想要在数据库中初始化一些表，最好在App一启动的时候就条用一下，会自动判定表是否已存在）；
 *
 *  @param classes 要插入的表的结构(Model类名),通过运行把指定的类作为一张表插入到数据库,类名=表名，类成员属性=字段名
 */
-(void)initTables:(NSArray*)classes;
/**
 *  关闭数据库
 */
//-(void)OPEN;
-(void)CLOSE;
/**
 *  通过类创建一个新的表
 *
 *  @param classz 类(类名=表名，类成员属性=字段名)
 */
-(void)createTable:(Class)classz;
/**
 *  在数据库中执行一段SQL语句
 *
 *  @param sql sql语句
 */
-(void)execSql:(NSString*)sql;
/**
 *  插入一条数据
 *
 *  @param data 模型(会根据模型里的keyid去搜索数据)
 */
-(void)insert:(id)data;
/**
 *  插入一组数据
 *
 *  @param datas 模型数组
 */
-(void)insertList:(NSArray*)datas;
/**
 *  删除一条数据
 *
 *  @param data 模型(会根据模型里的keyid去搜索数据)
 */
-(void)delete:(id)data;
/**
 *  修改一条数据
 *
 *  @param data 模型(会根据模型里的keyid去搜索数据)
 */
-(void)update:(id)data;
/**
 *  删除表内所有数据
 *
 *  @param classz 类(类名=表名，类成员属性=字段名)
 */
-(void)truncate:(Class)classz;





@end
