//
//  DAO.h
//  Demo
//
//  Created by 胡欣妍 on 2018/5/6.
//  Copyright © 2018年 胡欣妍. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DAO : NSObject{
    sqlite3 *db;
}
@property(strong, nonatomic) NSString *filePath;

//- (void) closeDB;
- (void)insert:(NSString *)_title :(NSString *)_text :(UIImage *) _img;
- (UIImage *)selecOrigintById: (NSInteger) _id;
- (NSMutableArray *)selectAllCompression;
- (void)updateTextById: (NSUInteger) _id :(NSString *) _text;
- (NSMutableArray *)selectLikeText: (NSString *) keyword;
- (void) deleteAll;
- (void) deleteById: (NSInteger) _id;
@end
