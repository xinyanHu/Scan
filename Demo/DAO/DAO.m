//
//  DAO.m
//  Demo
//
//  Created by 胡欣妍 on 2018/5/6.
//  Copyright © 2018年 胡欣妍. All rights reserved.
//

#import "DAO.h"
#import "../model/Item.h"

@implementation DAO
- (instancetype)init {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    _filePath = [documentsDirectory stringByAppendingPathComponent:@"scan.db"];
    NSLog(@"%@", _filePath);
    
    const char* path = [self.filePath UTF8String];
    if (sqlite3_open(path, &db) != SQLITE_OK) {
        NSLog(@"数据库打开失败");
    } else {
        NSString *sql = @"CREATE TABLE IF NOT EXISTS RECORD(id integer PRIMARY KEY autoincrement,title varchar(32), text text, time datetime, compression blob, origin blob);";
        
        const char* cSql = [sql UTF8String];
        if (sqlite3_exec(db, cSql, NULL, NULL, NULL) != SQLITE_OK) {
            NSLog(@"建表失败");
        }
    }
    
    sqlite3_close(db);
    return self;
}


-(void)insert:(NSString *)_title :(NSString *)_text :(UIImage *) _img{
    //压缩图
    NSData *compression = UIImageJPEGRepresentation(_img, 0.5);
    //原图
    NSData *origin = UIImagePNGRepresentation(_img);
    const char *path = [self.filePath UTF8String];
    if (sqlite3_open(path, &db) != SQLITE_OK) {
        NSLog(@"数据库打开失败");
    } else {
        const char *sql = "INSERT INTO RECORD VALUES(NULL, ?, ?, (SELECT datetime('now', 'localtime')), ?, ?)";
        
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) == SQLITE_OK)
        {
            const char* __title = [_title UTF8String];
            const char* __text = [_text UTF8String];
            
            sqlite3_bind_text(statement, 1, __title, -1, NULL);
            sqlite3_bind_text(statement, 2, __text, -1, NULL);
            sqlite3_bind_blob64(statement, 3, [compression bytes], [compression length], NULL);
            sqlite3_bind_blob64(statement, 4, [origin bytes], [origin length], NULL);
            if( sqlite3_step(statement) == SQLITE_DONE)
            {
                NSLog(@"已经写入数据");
            }
            sqlite3_finalize(statement);
        }
    }
    sqlite3_close(db);
}

-(UIImage *)selecOrigintById:(NSInteger) _id {
    const char *sql = "SELECT origin FROM RECORD WHERE id = ?";
    sqlite3_stmt *statement;
    const char *path = [self.filePath UTF8String];
    UIImage *img;
    if (sqlite3_open(path, &db) != SQLITE_OK) {
        NSLog(@"数据库打开失败");
    } else {
        if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_bind_int64(statement, 1, _id);
            if(sqlite3_step(statement)  == SQLITE_ROW) {
                int bytes = sqlite3_column_bytes(statement, 0);
                Byte *value = (Byte*)sqlite3_column_blob(statement, 0);
                
                if (value != NULL) {
                    NSData * data =[NSData dataWithBytes:value length:bytes];
                    img = [UIImage imageWithData:data];
                }
            }
            sqlite3_finalize(statement);
        }
    }
    
    sqlite3_close(db);
    return img;
}

-(NSMutableArray *)selectAllCompression {
    NSMutableArray *list = [NSMutableArray new];
    const char *sql = "SELECT id, title, text, time, compression FROM RECORD ORDER BY id DESC";
    sqlite3_stmt *statement;
    const char *path = [self.filePath UTF8String];
    
    if (sqlite3_open(path, &db) != SQLITE_OK) {
        NSLog(@"数据库打开失败");
    } else {
        if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) == SQLITE_OK) {
            while(sqlite3_step(statement) == SQLITE_ROW) {
                NSInteger _id = sqlite3_column_int(statement, 0);
                char *titleBuf = (char *)sqlite3_column_text(statement, 1);
                char *textBuf = (char *)sqlite3_column_text(statement, 2);
                char *timeBuf = (char *)sqlite3_column_text(statement, 3);
                
                NSString *title = [[NSString alloc] initWithUTF8String: titleBuf];
                NSString *text = [[NSString alloc] initWithUTF8String: textBuf];
                NSString *date = [[NSString alloc] initWithUTF8String: timeBuf];
                
                int bytes = sqlite3_column_bytes(statement, 4);
                Byte *value = (Byte*)sqlite3_column_blob(statement, 4);
                
                if (value != NULL) {
                    Item *item = [Item new];
                    NSData *data =[NSData dataWithBytes:value length:bytes];
                    [item set:_id :title :text :date :[UIImage imageWithData:data]];
                    [list addObject: item];
                }
            }
            sqlite3_finalize(statement);
        }
    }
    return list;
}

-(void)updateTextById:(NSUInteger)_id :(NSString *)_text {
    const char* path = [self.filePath UTF8String];
    if (sqlite3_open(path, &db) != SQLITE_OK) {
        NSLog(@"update--数据库打开失败");
    } else {
        NSString *sql = @"UPDATE RECORD SET text = ? WHERE id = ?";
        const char* cSql = [sql UTF8String];
        
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(db, cSql, -1, &statement, NULL) == SQLITE_OK) {
            const char* __text = [_text UTF8String];
            
            sqlite3_bind_text(statement, 1, __text, -1, NULL);
            sqlite3_bind_int64(statement, 2, _id);
            if (sqlite3_step(statement) != SQLITE_DONE) {
                NSLog(@"update--失败");
            }
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(db);
}

- (NSMutableArray *)selectLikeText:(NSString *)keyword {
    NSMutableArray *list = [NSMutableArray new];
    NSString *_sql = [[NSString alloc] initWithFormat: @"%@%@%@", @"SELECT id, title, text, time, compression FROM RECORD WHERE text LIKE '%", keyword, @"%' ORDER BY id DESC"];
    const char *sql = [_sql UTF8String];
    sqlite3_stmt *statement;
    const char *path = [self.filePath UTF8String];
    
    if (sqlite3_open(path, &db) != SQLITE_OK) {
        NSLog(@"数据库打开失败");
    } else {
        if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) == SQLITE_OK) {
            while(sqlite3_step(statement) == SQLITE_ROW) {
                NSInteger _id = sqlite3_column_int(statement, 0);
                char *titleBuf = (char *)sqlite3_column_text(statement, 1);
                char *textBuf = (char *)sqlite3_column_text(statement, 2);
                char *timeBuf = (char *)sqlite3_column_text(statement, 3);
                
                NSString *title = [[NSString alloc] initWithUTF8String: titleBuf];
                NSString *text = [[NSString alloc] initWithUTF8String: textBuf];
                NSString *date = [[NSString alloc] initWithUTF8String: timeBuf];
                
                int bytes = sqlite3_column_bytes(statement, 4);
                Byte *value = (Byte*)sqlite3_column_blob(statement, 4);
                
                if (value != NULL) {
                    Item *item = [Item new];
                    NSData *data =[NSData dataWithBytes:value length:bytes];
                    [item set:_id :title :text :date :[UIImage imageWithData:data]];
                    [list addObject: item];
                }
            }
            sqlite3_finalize(statement);
        }
    }
    sqlite3_close(db);
    return list;
}

-(void)deleteAll {
    const char* path = [self.filePath UTF8String];
    if (sqlite3_open(path, &db) != SQLITE_OK) {
        NSLog(@"deleteAll--数据库打开失败");
    } else {
        NSString *sql = @"DELETE FROM RECORD";
        const char* cSql = [sql UTF8String];
        
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(db, cSql, -1, &statement, NULL) == SQLITE_OK) {
            if (sqlite3_step(statement) != SQLITE_DONE) {
                NSLog(@"deleteAll--失败");
            }
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(db);
}

-(void)deleteById:(NSInteger)_id {
    const char* path = [self.filePath UTF8String];
    if (sqlite3_open(path, &db) != SQLITE_OK) {
        NSLog(@"deleteById--数据库打开失败");
    } else {
        NSString *sql = @"DELETE FROM RECORD WHERE ID IS ?";
        const char* cSql = [sql UTF8String];
        
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(db, cSql, -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_bind_int64(statement, 1, _id);
            
            if (sqlite3_step(statement) != SQLITE_DONE) {
                NSLog(@"deleteById--删除失败");
            }
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(db);
}

@end
