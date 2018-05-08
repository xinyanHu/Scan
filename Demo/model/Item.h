//
//  Item.h
//  Demo
//
//  Created by 胡欣妍 on 2018/5/6.
//  Copyright © 2018年 胡欣妍. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface Item : NSObject
@property NSInteger _id;
@property(nonatomic, copy) NSString* _title;
@property(nonatomic, copy) NSString* _text;
@property(nonatomic, copy) NSString* _time;
@property(nonatomic, strong) UIImage* _compression;

- (void)set:(NSInteger) _id :(NSString *)_title :(NSString *) _text :(NSString *) _time :(UIImage *) _compression;

@end
