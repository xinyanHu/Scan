//
//  PreviewViewController.m
//  Demo
//
//  Created by 胡欣妍 on 2018/5/6.
//  Copyright © 2018年 胡欣妍. All rights reserved.
//

#import "PreviewViewController.h"
#import "../../DAO/DAO.h"

@interface PreviewViewController ()
@property(nonatomic, strong) DAO *dao;
@end

@implementation PreviewViewController {
    CGFloat currentScale;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _dao = [DAO new];
    UIImage *img = [_dao selecOrigintById: _ItemId];
    _imageView.image = img;
    
    [self addGestureRecognizerToView:_imageView];
    
    [_imageView setUserInteractionEnabled:YES];
    [_imageView setMultipleTouchEnabled:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 添加所有的手势
- (void) addGestureRecognizerToView:(UIView *)view
{
    // 缩放手势
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [view addGestureRecognizer:pinchGestureRecognizer];
    
    // 移动手势
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [view addGestureRecognizer:panGestureRecognizer];
}

// 处理移动手势
- (void) pinchView:(UIPinchGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        currentScale = sender.scale;
    } else if(sender.state == UIGestureRecognizerStateBegan && currentScale != 0.0f){
        sender.scale = currentScale;
    }
    self.imageView.transform = CGAffineTransformMakeScale(sender.scale, sender.scale);
}

// 处理拖拉手势
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = panGestureRecognizer.view;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    currentScale = 0.0f;
    self.imageView.transform = CGAffineTransformMakeScale(0, 0);
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
