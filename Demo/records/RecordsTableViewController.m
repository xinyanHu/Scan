//
//  RecordsTableViewController.m
//  Demo
//
//  Created by 胡欣妍 on 2018/5/6.
//  Copyright © 2018年 胡欣妍. All rights reserved.
//

#import "RecordsTableViewController.h"
#import "../DAO/DAO.h"
#import "../model/Item.h"
#import "cell/TableViewCell.h"
#import "preview/PreviewViewController.h"
#import "fullText/FullTextViewController.h"

@interface RecordsTableViewController ()<UISearchBarDelegate, UISearchResultsUpdating>
@property(nonatomic, strong) UISearchController *searchController;
@property(nonatomic, strong) NSMutableArray *list;
@property(nonatomic, strong) DAO *dao;
@end

@implementation RecordsTableViewController

static NSString * const reuseIdentifier = @"TableCellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    _dao = [DAO new];
    [self prapareCellNoti];
    //    搜索栏
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.searchResultsUpdater = self;
    _searchController.dimsBackgroundDuringPresentation = false;
    self.tableView.tableHeaderView = _searchController.searchBar;
    self.definesPresentationContext = YES;
    [_searchController.searchBar sizeToFit];
    //数据源
    _list = [_dao selectAllCompression];
}

- (void)viewDidAppear:(BOOL)animated {
    _list = [_dao selectAllCompression];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchText = _searchController.searchBar.text;
    _list = [_dao selectLikeText:searchText];
    [self.tableView reloadData];
}

#pragma mark - 接收通知
-(void)prapareCellNoti{
    NSString *imageClicked = @"CellImageClicked";
    [[NSNotificationCenter defaultCenter] addObserverForName:imageClicked object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSInteger ItemId = [note.object integerValue];
        PreviewViewController *vc = [PreviewViewController new];
        vc.ItemId = ItemId;
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        self.hidesBottomBarWhenPushed = NO;
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    Item *current = [_list objectAtIndex: indexPath.row];
    
    cell.ItemId = current._id;
    cell.title.text = current._text;
    cell.time.text = current._time;
    cell.compression.image = current._compression;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FullTextViewController *vc = [FullTextViewController new];
    Item *current = [_list objectAtIndex: indexPath.row];
    vc.text = current._text;
    vc.ItemId = current._id;
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}

#pragma mark - UITableViewEditing
//先要设Cell可编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

//定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

//进入编辑模式，按下出现的编辑按钮后,进行删除操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Item *i = [_list objectAtIndex:indexPath.row];
        [_dao deleteById:i._id];
        [_list removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
    }
}

//修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}


#pragma mark - clear
- (IBAction)clear:(id)sender {
    if ([_list count] > 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle: @""
                                                                                 message: @"确认清空？"
                                                                          preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle: @"取消"
                                                               style: UIAlertActionStyleCancel
                                                             handler: ^(UIAlertAction * action) {
                                                             }];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle: @"确定"
                                                           style: UIAlertActionStyleDefault
                                                         handler: ^(UIAlertAction * action) {
                                                             [self->_list removeAllObjects];
                                                             [self->_dao deleteAll];
                                                             [self.tableView reloadData];
                                                         }];
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }

}
@end
