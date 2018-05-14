//
//  FullTextViewController.m
//  Demo
//
//  Created by 胡欣妍 on 2018/5/6.
//  Copyright © 2018年 胡欣妍. All rights reserved.
//

#import "FullTextViewController.h"
#import "../../DAO/DAO.h"

@interface FullTextViewController ()

@end

@implementation FullTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
     _textView.text = _text;
    [self initToolBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
// 在视图要消失前，更新RECORD

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    DAO *dao = [DAO new];
    [dao updateTextById:_ItemId :_textView.text];
}

- (void) initToolBar {
    UIToolbar * topView = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 0, 0, 40)];
    UIBarButtonItem *btnSpace = [[UIBarButtonItem alloc]
                                 initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace
                                 target: self
                                 action: nil];
    UIBarButtonItem *btnDone  = [[UIBarButtonItem alloc]
                                 initWithBarButtonSystemItem: UIBarButtonSystemItemDone
                                 target: self
                                 action: @selector(dismissKeyBoard)];
    NSArray * buttonsArray = [NSArray arrayWithObjects: btnSpace, btnDone, nil];
    
    [topView setItems:buttonsArray];
    [_textView setInputAccessoryView:topView];
}

//收起键盘
-(IBAction)dismissKeyBoard {
    [_textView resignFirstResponder];
}

@end
