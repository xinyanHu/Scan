//
//  PhotosCollectionViewController.m
//  Demo
//
//  Created by 胡欣妍 on 2018/5/6.
//  Copyright © 2018年 胡欣妍. All rights reserved.
//

#import <Photos/Photos.h>
#import <AipOcrSdk/AipOcrSdk.h>
#import "PhotosCollectionViewController.h"
#import "cell/CollectionViewCell.h"
#import "../DAO/DAO.h"
#import "preview/ConfirmViewController.h"

#define COL_NUM 3

@interface PhotosCollectionViewController ()
@property(nonatomic, strong) PHFetchResult<PHAsset *> *assets;
@property(nonatomic, strong) UIImage* result;
@end

@implementation PhotosCollectionViewController {
    // 默认的识别成功的回调
    void (^_successHandler)(id);
    // 默认的识别失败的回调
    void (^_failHandler)(NSError *);
}

static NSString * const reuseIdentifier = @"CollectionCellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    _assets = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options: nil];
    
    
    [[AipOcrService shardService] authWithAK:@"rUANGL00GQ0i7cnGSnLuMGSl" andSK:@"kWhpsG0jK8qQpe5roTuwz06ZiTHHsITN"];
    [self configCallback];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - camera
- (IBAction)camera:(id)sender {
    UIViewController * vc = [AipGeneralVC ViewControllerWithHandler:^(UIImage *image) {
        // 在这个block里，image即为切好的图片，可自行选择如何处理
        self->_result = image;
        NSDictionary *options = @{@"language_type": @"CHN_ENG", @"detect_direction": @"true"};
        [[AipOcrService shardService] detectTextFromImage:image
                                              withOptions:options
                                           successHandler:self->_successHandler
                                              failHandler:self->_failHandler];
    }];
    [self presentViewController:vc animated:YES completion:nil];
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
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
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
                                                                     [weakSelf dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
            [alertController addAction:cancelAction];
            [weakSelf presentViewController:alertController animated:YES completion:nil];
        }];
    };
}
#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if ([_assets count] % COL_NUM == 0) {
        return [_assets count] / COL_NUM;
    } else {
        return [_assets count] / COL_NUM + 1;
    }
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return COL_NUM;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSInteger index = indexPath.section * COL_NUM + indexPath.row;
    if ([_assets count] <= index) {
        //防止下标越界
        return cell;
    }
    
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.synchronous = YES;
    PHAsset *current = [_assets objectAtIndex: index];
    
    CGSize size = CGSizeMake(100, 100);
    [[PHImageManager defaultManager] requestImageForAsset:current
                                               targetSize:size
                                              contentMode:PHImageContentModeDefault
                                                  options:options
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
                                                    cell.imageView.image = result;
                                                });
                                            }];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%ld, %ld, count: %ld", indexPath.section, indexPath.row, [_assets count]);
    
    NSInteger index = indexPath.section * COL_NUM + indexPath.row;
    if(index >= [_assets count])
        return;
    ConfirmViewController *vc = [ConfirmViewController new];
    vc.asset = [_assets objectAtIndex: index];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}



@end
