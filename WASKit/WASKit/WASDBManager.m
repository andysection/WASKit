//
//  WASDBManager.m
//  WASKit
//
//  Created by admin on 17/2/28.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "WASDBManager.h"

static WASDBManager * s_nkdbo_instance = nil;
static long long  key_sequence = 0;

@implementation WASDBManager

+(WASDBManager*)share
{
    @synchronized(self)
    {
        if( s_nkdbo_instance == nil )
        {
            
            s_nkdbo_instance =   [[WASDBManager alloc] init];
            [s_nkdbo_instance OPEN];
            key_sequence = [s_nkdbo_instance init_sequence];
            
        }
        return s_nkdbo_instance;
    }
}

+(id)allocWithZone:(struct _NSZone *)zone
{
    
    @synchronized(self)
    {
        if( s_nkdbo_instance == nil )
        {
            s_nkdbo_instance = [[super allocWithZone:zone]init];
        }
        
    }
    return s_nkdbo_instance;
    
}


-(void)setValue:(id)data  stmt:(sqlite3_stmt*)stmt
{
    
    
    int col_count = sqlite3_column_count(stmt);
    
    for(int i=0;i<col_count;i++)
    {
        const char * col_name = sqlite3_column_name(stmt,i);
        
        const char * col_type = sqlite3_column_decltype(stmt,i);
        
        if( strstr(col_type,"INTEGER") || strstr(col_type, "int") )
        {
            
            [data setValue:[NSNumber numberWithInt:sqlite3_column_int(stmt, i)] forKey:[NSString stringWithFormat:@"%s",col_name] ];
        }
        else if( strstr(col_type, "varchar") )
        {
            
            const unsigned char * str = sqlite3_column_text(stmt, i);
            if( str && strlen(str) > 0 )
                
                [data setValue:[[NSString alloc]initWithCString:str encoding:NSUTF8StringEncoding] forKey:[NSString stringWithFormat:@"%s",col_name] ];
            
        }
        
    }
    
    
    
    
}



-(NSArray*)listByClass:(Class)classz sql:(NSString*)where
{
    
    const char * tablename = class_getName(classz);
    NSLog(@"select table:classz :%s", tablename );
    
    // unsigned int outCount, i;
    // objc_property_t *properties = class_copyPropertyList(classz, &outCount);
    
    NSMutableArray * datas = [[NSMutableArray alloc]init];
    
    NSString * whereStr = @"";
    if( where && where.length > 0  )
    {
        if( [where rangeOfString:@"where"].length == 0  )
        {
            whereStr = [NSString stringWithFormat:@" where %@",where];
        }
        else
            whereStr = where;
    }
    
    NSString * sql = [NSString stringWithFormat:@"select * from %s %@",tablename,whereStr ];
    sqlite3_stmt *statement;
    
    int ret = sqlite3_prepare_v2(m_db,[sql UTF8String],-1,&statement,NULL);
    if(  ret == SQLITE_OK )
    {
        
        
        
        while ( sqlite3_step(statement) == SQLITE_ROW )
        {
            
            id obj = [[classz alloc]init];
            [self setValue:obj stmt:statement];
            [datas addObject:obj];
            
        }
        
    }
    
    return datas;
}


-(void)initTables:(NSArray*)classes
{
    
    
    //NSLog(@"int value:%ld", [self get_yyyymmddhhmmss]);
    
    
    
    if( !m_db )
        return;
    sqlite3_stmt *statement;
    
    const char *querystr = "select name from sqlite_master ";
    int ret = sqlite3_prepare_v2(m_db,querystr,-1,&statement,NULL);
    if(  ret == SQLITE_OK )
    {
        
        NSString * tables = @",";
        
        while ( sqlite3_step(statement) == SQLITE_ROW )
        {
            
            
            
            // sqlite3_column_name(statement,i)
            
            tables = [tables stringByAppendingString:[NSString stringWithUTF8String: (const char *)sqlite3_column_text(statement, 0)  ]];
            tables = [tables stringByAppendingString:@","];
            
        }
        
        NSLog(@"tables:%@",tables);
        
        
        for(Class classz in classes )
        {
            NSString * tablename = [NSString stringWithFormat:@",%s,",class_getName(classz)];
            NSRange  range = [tables rangeOfString:tablename];
            
            if( range.length == 0 )
            {
                
                [self createTable:classz];
                
            }
        }
        
        
        
        
        
    }
    else
        NSLog(@"queryByTable error code:%d:%s",ret, sqlite3_errmsg(m_db) );
    
    sqlite3_finalize(statement);
    
    
    
}

-(void)createTable:(Class)classz
{
    const char * tablename = class_getName(classz);
    NSLog(@"create table:classz :%s", tablename );
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(classz, &outCount);
    
    NSString * sql = [NSString stringWithFormat: @"CREATE TABLE IF NOT EXISTS %s(",tablename ];
    for(int i=0;i<outCount;i++)
    {
        objc_property_t property = properties[i];
        
        const  char * propertyName = property_getName(property);
        
        
        
        const char * pa =   property_getAttributes(property);
        
        if( strstr("keyid",propertyName) )
        {
            sql = [sql stringByAppendingString:@"keyid varchar PRIMARY KEY "];
            continue;
        }
        if( propertyName[ 0] == '_' )
            continue;
        
        
        
        if( strstr(pa,"NSString") )
        {
            
            sql = [sql stringByAppendingString:  [NSString stringWithFormat:@",%s varchar",propertyName]   ];
            
        }
        else if( strstr(pa,"Ti"))
        {
            
            sql = [sql stringByAppendingString:  [NSString stringWithFormat:@",%s int",propertyName]   ];
        }
        
        
        
        
        // NSLog(@"property name:%@ ::%s",propertyName,property_getAttributes(property));
        
        
    }
    sql = [sql stringByAppendingString:@")"];
    
    
    [self execSql:sql];
    NSLog(@"create sql:%@",sql);
    
}



-(void)OPEN
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    NSString *database_path = [documents stringByAppendingPathComponent:NKDBO_DBNAME];
    NSLog(@"数据库->: %@",database_path);
    if (sqlite3_open([database_path UTF8String], &m_db) != SQLITE_OK) {
        sqlite3_close(m_db);
        m_db = NULL;
        NSLog(@"数据库打开失败 %@",database_path);
    }
    
    
    
    
}
-(void)CLOSE
{
    
    if( m_db )
    {
        sqlite3_close(m_db);
        m_db = NULL;
    }
}



-(void)execSql:(NSString*)sql
{
    if( !m_db )
        return;
    char *err;
    if (sqlite3_exec(m_db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        
        NSLog(@"exe sql error!:%s",err);
    }
    
}

-(void)insert:(id)data;
{
    
    const char * tablename = class_getName([data class]);
    
    // NSString * sql = [NSString stringWithFormat:@"insert into %s(",tablename];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([data class], &outCount);
    
    NSString * fields = @"keyid";
    NSString * key =  [self next_sequence];
    NSString * values = [ NSString stringWithFormat:@"'%@'",key ];
    
    
    for(i=0;i<outCount;i++)
    {
        objc_property_t property = properties[i];
        
        const  char * propertyName = property_getName(property);
        const char * pa =   property_getAttributes(property);
        
        if( strstr("keyid",propertyName) )
            continue;
        if( propertyName[0] == '_' )
            continue;
        
        NSString * propertyName_S = [NSString stringWithUTF8String:propertyName];
        
        if( strstr(pa,"NSString") )
        {
            
            NSString *value = [data valueForKey: propertyName_S];
            if( !value )
                continue;
            
            //特殊字符转义
            if (value && [propertyName_S isEqualToString:@"usernickname"])
            {
                value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                //                value = [value stringByReplacingOccurrencesOfString:@"/" withString:@"//"];
                value = [value stringByReplacingOccurrencesOfString:@"[" withString:@"/["];
                value = [value stringByReplacingOccurrencesOfString:@"]" withString:@"/]"];
                value = [value stringByReplacingOccurrencesOfString:@"%" withString:@"/%"];
                value = [value stringByReplacingOccurrencesOfString:@"&" withString:@"/&"];
                //                value = [value stringByReplacingOccurrencesOfString:@"_" withString:@"/_"];
                value = [value stringByReplacingOccurrencesOfString:@"(" withString:@"/("];
                value = [value stringByReplacingOccurrencesOfString:@")" withString:@"/)"];
            }
            
            fields = [fields stringByAppendingString: [NSString stringWithFormat:@",%s",propertyName]];
            values = [values stringByAppendingString:[NSString stringWithFormat:@",'%@'",value] ];
            
            
            
        }
        else if( strstr(pa,"Ti"))
        {
            int value = [[data valueForKey: propertyName_S] intValue];
            
            fields = [fields stringByAppendingString: [NSString stringWithFormat:@",%s",propertyName]];
            values = [values stringByAppendingString:[NSString stringWithFormat:@",%d",value] ];
            
            
        }
        
        // NSLog(@"property name:%@ ::%s",propertyName,property_getAttributes(property));
        
    }
    
    
    NSLog(@"插入数据语句中的数据：==%@",values);
    
    
    NSString * sql = [NSString stringWithFormat:@"insert into %s(%@) values(%@)",tablename,fields,values];
    
    
    NSLog(@"插入数据语句:%@",sql);
    
    /*
     sql = [sql stringByAppendingString:[fields substringToIndex:fields.length-1]];
     sql = [sql stringByAppendingString:@") values("];
     sql = [sql stringByAppendingString:[values substringToIndex:values.length-1]];
     sql = [sql stringByAppendingString:@")"];
     */
    
    //    NSLog(@"%@", sql);
    [self execSql:sql];
    [data setValue:key forKey:@"keyid"];
    
}


-(void)insert_stmt:(id)data
{
    
    sqlite3_stmt *stmt;
    
    const char * tablename = class_getName([data class]);
    
    NSString * sql = [NSString stringWithFormat:@"insert into %s(",tablename];
    
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([data class], &outCount);
    
    NSString * fields = @"";
    NSString * values = @"";
    
    int k=1;
    for(i=0;i<outCount;i++)
    {
        objc_property_t property = properties[i];
        
        const  char * propertyName = property_getName(property);
        
        const char * pa =   property_getAttributes(property);
        
        if( strstr("keyid",propertyName) )
            continue;
        if( propertyName[0] == '_' )
            continue;
        
        NSString * propertyName_S = [NSString stringWithUTF8String:propertyName];
        
        if( strstr(pa,"NSString") )
        {
            
            NSString * value = [data valueForKey: propertyName_S];
            if( !value )
                continue;
            
            fields = [fields stringByAppendingString: [NSString stringWithFormat:@"%s,",propertyName]];
            values = [values stringByAppendingString:@"?,"];
            
            sqlite3_bind_text(stmt,k++, [value UTF8String],(int)value.length,SQLITE_TRANSIENT);
            
        }
        else if( strstr(pa,"Ti"))
        {
            int value = [[data valueForKey: propertyName_S] intValue];
            
            fields = [fields stringByAppendingString: [NSString stringWithFormat:@"%s,",propertyName]];
            values = [values stringByAppendingString:@"?,"];
            
            sqlite3_bind_int(stmt,k++,value);
        }
        
        // NSLog(@"property name:%@ ::%s",propertyName,property_getAttributes(property));
        
    }
    
    sql = [sql stringByAppendingString:[fields substringToIndex:fields.length-1]];
    sql = [sql stringByAppendingString:@") values("];
    sql = [sql stringByAppendingString:[values substringToIndex:values.length-1]];
    sql = [sql stringByAppendingString:@")"];
    
    NSLog(@"insert sql:%@",sql);
    char *err;
    int ret = sqlite3_prepare_v2(m_db,[sql UTF8String],-1,&stmt,&err);
    
    if(  ret == SQLITE_OK )
    {
        NSLog(@"insert success");
        
    }
    else
    {
        
        NSLog(@"insert error:%s",err);
        
    }
    
    sqlite3_finalize(stmt);
    
    //sqlite3_bind_int(stmt,1,1);
    // sqlite3_bind_text(stmt,2, "", -1,SQLITE_TRANSIENT);
    
    //sqlite3_prepare_v2(m_db, sql, -1, &stmt, NULL);
    
    NSLog(@"int value:%ld", [self get_yyyymmddhhmmss]);
    
}
-(void)insertList:(NSArray*)datas
{
    @try{
        char *errorMsg;
        if (sqlite3_exec(m_db, "BEGIN", NULL, NULL, &errorMsg)==SQLITE_OK)
        {
            NSLog(@"启动事务成功");
            sqlite3_free(errorMsg);
            
            for(id obj in datas)
                [self insert:obj];
            
            
            if (sqlite3_exec(m_db, "COMMIT", NULL, NULL, &errorMsg)==SQLITE_OK)
                NSLog(@"提交事务成功");
            sqlite3_free(errorMsg);
        }
        else sqlite3_free(errorMsg);
    }
    @catch(NSException *e)
    {
        char *errorMsg;
        if (sqlite3_exec(m_db, "ROLLBACK", NULL, NULL, &errorMsg)==SQLITE_OK)
            NSLog(@"回滚事务成功");
        sqlite3_free(errorMsg);
    }
    @finally{}
    
    
}


-(NSString*)next_sequence
{
    
    return [NSString stringWithFormat:@"%lld",key_sequence++];
    
}

-(long long)init_sequence
{
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"YYYYMMddhhmmss"];
    NSString *date =  [formatter stringFromDate:[NSDate date]];
    NSString *timeLocal = [[NSString alloc] initWithFormat:@"%@", date];
    
    return timeLocal.longLongValue;
    
    
}



-(long)get_yyyymmddhhmmss
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *now;
    
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    now=[NSDate date];
    comps = [calendar components:unitFlags fromDate:now];
    
    NSInteger year = [comps year];
    NSInteger month = [comps month];
    NSInteger     day = [comps day];
    NSInteger     hour = [comps hour];
    NSInteger     min = [comps minute];
    NSInteger     sec = [comps second];
    
    return [NSString stringWithFormat:@"%ld%02ld%2ld%02ld%02ld%02ld",(long)year,(long)month,(long)day,(long)hour,(long)min,(long)sec].longLongValue;
    
    
}


-(void)delete:(id)data
{
    const char * tablename = class_getName([data class]);
    
    
    NSString * keyid = [data valueForKey:@"keyid"] ;
    
    NSString * sql = [NSString stringWithFormat:@"delete from %s where keyid='%@'",tablename,keyid];
    
    [self execSql:sql];
    
}

-(void)update:(id)data
{
    
    const char * tablename = class_getName([data class]);
    
    NSString * sql = [NSString stringWithFormat:@"update %s set ",tablename];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([data class], &outCount);
    
    for(i=0;i<outCount;i++)
    {
        objc_property_t property = properties[i];
        
        const  char * propertyName = property_getName(property);
        const char * pa =   property_getAttributes(property);
        
        if( strstr("keyid",propertyName) )
            continue;
        if( propertyName[0] == '_' )
            continue;
        
        NSString * propertyName_S = [NSString stringWithUTF8String:propertyName];
        
        if( strstr(pa,"NSString") )
        {
            
            NSString *value = [data valueForKey: propertyName_S];
            
            if( !value )
                continue;
            
            //特殊字符转义
            if (value && [propertyName_S isEqualToString:@"usernickname"])
            {
                value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                //                value = [value stringByReplacingOccurrencesOfString:@"/" withString:@"//"];
                value = [value stringByReplacingOccurrencesOfString:@"[" withString:@"/["];
                value = [value stringByReplacingOccurrencesOfString:@"]" withString:@"/]"];
                value = [value stringByReplacingOccurrencesOfString:@"%" withString:@"/%"];
                value = [value stringByReplacingOccurrencesOfString:@"&" withString:@"/&"];
                //                value = [value stringByReplacingOccurrencesOfString:@"_" withString:@"/_"];
                value = [value stringByReplacingOccurrencesOfString:@"(" withString:@"/("];
                value = [value stringByReplacingOccurrencesOfString:@")" withString:@"/)"];
            }
            
            
            sql = [sql stringByAppendingString: [NSString stringWithFormat:@"%s='%@',",propertyName,value]];
            
        }
        else if( strstr(pa,"Ti"))
        {
            
            
            int value = [[data valueForKey: propertyName_S] intValue];
            
            sql = [sql stringByAppendingString: [NSString stringWithFormat:@"%s=%d,",propertyName,value]];
            
            
        }
        
        // NSLog(@"property name:%@ ::%s",propertyName,property_getAttributes(property));
        
        
    }
    
    NSString * keyid = [data valueForKey:@"keyid"] ;
    sql = [sql substringToIndex:sql.length-1];
    
    
    
    sql = [sql stringByAppendingString:[ NSString stringWithFormat:@" where keyid='%@'",keyid ]];
    
    
    //NSLog(@"")
    
    
    //    NSLog(@"SQL语句：==%@",sql);
    
    [self execSql:sql];
    
    
    
    
}

-(void)truncate:(Class)classz{
    const char * tablename = class_getName(classz);
    NSLog(@"truncate table:classz :%s", tablename );
    
    NSString * sql = [NSString stringWithFormat: @"DELETE FROM %s",tablename ];
    
    [self execSql:sql];
    NSLog(@"truncate sql:%@",sql);
    
}


@end
