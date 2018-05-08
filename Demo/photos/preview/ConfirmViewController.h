//
//  ConfirmViewController.h
//  Demo
//
//  Created by 胡欣妍 on 2018/5/6.
//  Copyright © 2018年 胡欣妍. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface ConfirmViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property(nonatomic, strong) PHAsset* asset;
@end
