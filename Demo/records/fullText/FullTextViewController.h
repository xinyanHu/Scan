//
//  FullTextViewController.h
//  Demo
//
//  Created by 胡欣妍 on 2018/5/6.
//  Copyright © 2018年 胡欣妍. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FullTextViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property(nonatomic, copy) NSString* text;
@property NSInteger ItemId;
@end
