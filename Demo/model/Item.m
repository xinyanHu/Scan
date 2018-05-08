//
//  Item.m
//  Demo
//
//  Created by 胡欣妍 on 2018/5/6.
//  Copyright © 2018年 胡欣妍. All rights reserved.
//

#import "Item.h"

@implementation Item
- (void)set:(NSInteger)_id :(NSString *)_title :(NSString *)_text :(NSString *)_time :(UIImage *)_compression {
    __id = _id;
    __title = [_title copy];
    __text = [_text copy];
    __time = [_time copy];
    __compression = _compression;
}
@end
