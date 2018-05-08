//
//  TableViewCell.m
//  Demo
//
//  Created by 胡欣妍 on 2018/5/6.
//  Copyright © 2018年 胡欣妍. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clicked:)];
    _compression.userInteractionEnabled = YES;
    [_compression addGestureRecognizer:tapped];
}

-(void)clicked :(id) sender {
    NSLog(@"cell image clicked %ld", _ItemId);
    NSString *imageClicked = @"CellImageClicked";
    //cellID回传
    [[NSNotificationCenter defaultCenter]postNotificationName:imageClicked object: @(_ItemId)];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
