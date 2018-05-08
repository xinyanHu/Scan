//
//  ConfirmViewController.m
//  Demo
//
//  Created by 胡欣妍 on 2018/5/6.
//  Copyright © 2018年 胡欣妍. All rights reserved.
//

#import <AipOcrSdk/AipOcrSdk.h>
#import "ConfirmViewController.h"
#import "../../DAO/DAO.h"

@interface ConfirmViewController (){
    void (^_successHandler)(id);
    // 默认的识别失败的回调
    void (^_failHandler)(NSError *);
    
    CGFloat currentScale;
}
@property (strong, nonatomic) UIImage* result;
@end

@implementation ConfirmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configCallback];
    [self loadImage];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)confirm:(id)sender {
    [[AipOcrService shardService] authWithAK:@"rUANGL00GQ0i7cnGSnLuMGSl" andSK:@"kWhpsG0jK8qQpe5roTuwz06ZiTHHsITN"];
    NSDictionary *options = @{@"language_type": @"CHN_ENG", @"detect_direction": @"true"};
    [[AipOcrService shardService] detectTextFromImage:_result
                                          withOptions:options
                                       successHandler:_successHandler
                                          failHandler:_failHandler];
}

- (void)loadImage {
    if (!_asset)
        return;
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.resizeMode = PHImageRequestOptionsResizeModeNone;
    options.synchronous = YES;
    CGSize size = CGSizeMake(_asset.pixelWidth, _asset.pixelHeight);
    [[PHImageManager defaultManager] requestImageForAsset:_asset
                                               targetSize:size
                                              contentMode:PHImageContentModeDefault
                                                  options:options
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    self->_imageView.image = result;
                                                    self->_result = result;
                                                });
                                            }];
}

#pragma mark - CallBack
- (void)configCallback {
    __weak typeof(self) weakSelf = self;
    
    // 这是默认的识别成功的回调
    _successHandler = ^(id result){
        NSMutableString *message = [NSMutableString string];
        
        if(result[@"words_result"]){
            if([result[@"words_result"] isKindOfClass:[NSDictionary class]]){
                [result[@"words_result"] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    if([obj isKindOfClass:[NSDictionary class]] && [obj objectForKey:@"words"]){
                        [message appendFormat:@"%@: %@\n", key, obj[@"words"]];
                    }else{
                        [message appendFormat:@"%@: %@\n", key, obj];
                    }
                    
                }];
            }else if([result[@"words_result"] isKindOfClass:[NSArray class]]){
                for(NSDictionary *obj in result[@"words_result"]){
                    if([obj isKindOfClass:[NSDictionary class]] && [obj objectForKey:@"words"]){
                        [message appendFormat:@"%@", obj[@"words"]];
                    }else{
                        [message appendFormat:@"%@", obj];
                    }
                    
                }
            }
            
        }else{
            [message appendFormat:@"%@", result];
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            DAO *dao = [DAO new];
            if (weakSelf.result) {
                if ([message length] > 20) {
                    [dao insert:[message substringWithRange: NSMakeRange(0, 20)] :message : weakSelf.result];
                } else {
                    [dao insert:message :message : weakSelf.result];
                }
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
    };
    
    _failHandler = ^(NSError *error){
        NSLog(@"%@", error);
        NSString *msg = [NSString stringWithFormat:@"%li:%@", (long)[error code], [error localizedDescription]];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle: @"识别失败"
                                                                                     message: msg
                                                                              preferredStyle: UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle: @"确定"
                                                                   style: UIAlertActionStyleCancel
                                                                 handler: ^(UIAlertAction * action) {
                                                                     [weakSelf.navigationController popViewControllerAnimated:YES];
                                                                 }];
            [alertController addAction:cancelAction];
            [weakSelf presentViewController:alertController animated:YES completion:nil];
        }];
    };
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
