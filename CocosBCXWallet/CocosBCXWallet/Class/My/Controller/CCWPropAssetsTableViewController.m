//
//  CCWPropAssetsTableViewController.m
//  CocosBCXWallet
//
//  Created by 邵银岭 on 2019/2/26.
//  Copyright © 2019年 邵银岭. All rights reserved.
//

#import "CCWPropAssetsTableViewController.h"
#import "CCWPropAssetsTableViewCell.h"

@interface CCWPropAssetsTableViewController ()<DZNEmptyDataSetSource, DZNEmptyDataSetDelegate,CCWPropAssetsCellDelegate>
{
    NSInteger page;
}
/** <#视图#> */
@property (nonatomic, strong) NSMutableArray *propAssetArray;
@end

@implementation CCWPropAssetsTableViewController

- (NSMutableArray *)propAssetArray
{
    if (!_propAssetArray) {
        _propAssetArray = [NSMutableArray array];
    }
    return _propAssetArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.rowHeight = 100;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    [self.tableView.mj_header beginRefreshing];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
}

- (void)loadData
{
    page = 1;
    CCWWeakSelf;
    [CCWSDKRequest CCW_QueryAccountNHAsset:CCWAccountId WorldView:@[] PageSize:10 Page:page Success:^(NSArray *responseObject) {
        // 结束刷新
        [weakSelf.tableView.mj_header endRefreshing];
        weakSelf.propAssetArray = [CCWNHAssetsModel mj_objectArrayWithKeyValuesArray:[responseObject firstObject]];
        [weakSelf.tableView reloadData];
    } Error:^(NSString * _Nonnull errorAlert, id  _Nonnull responseObject) {
        [weakSelf.view makeToast:CCWLocalizable(@"网络繁忙，请检查您的网络连接")];
        // 结束刷新
        [weakSelf.tableView.mj_header endRefreshing];
    }];
}

// 上拉加载更多
- (void)loadMoreData
{
    page += 1;
    CCWWeakSelf;
    [CCWSDKRequest CCW_QueryAccountNHAsset:CCWAccountId WorldView:@[] PageSize:10 Page:page Success:^(NSArray *responseObject) {
        // 结束刷新
        [weakSelf.tableView.mj_footer endRefreshing];
        [weakSelf.propAssetArray addObjectsFromArray:[CCWNHAssetsModel mj_objectArrayWithKeyValuesArray:[responseObject firstObject]]];
        [weakSelf.tableView reloadData];
    } Error:^(NSString * _Nonnull errorAlert, id  _Nonnull responseObject) {
        [weakSelf.view makeToast:CCWLocalizable(@"网络繁忙，请检查您的网络连接")];
        // 结束刷新
        [weakSelf.tableView.mj_footer endRefreshing];
    }];
}

#pragma mark - tableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.propAssetArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCWPropAssetsTableViewCell *cell = [CCWPropAssetsTableViewCell cellWithTableView:tableView WithIdentifier:@"CCWPropAssetsTableViewCell"];
    cell.delegate = self;
    cell.nhAssetModel = self.propAssetArray[indexPath.row];
    return cell;
}

// 出售资产
- (void)CCWPropAssetCellSellClick:(CCWPropAssetsTableViewCell *)propAssetCell
{
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - DZNEmptyDataSetSource Methods
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"noData"];
}

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIColor whiteColor];
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    return  -90;
}

#pragma mark - DZNEmptyDataSetDelegate Methods
- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return NO;
}
@end
