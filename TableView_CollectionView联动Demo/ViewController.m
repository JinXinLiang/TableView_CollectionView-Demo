//
//  ViewController.m
//  TableView_CollectionView联动Demo
//
//  Created by Eiwodetianna on 16/8/30.
//  Copyright © 2016年 Eiwodetianna. All rights reserved.
//

#import "ViewController.h"


NSInteger tableViewCellCount = 10;
NSInteger collectionViewCellCount = 40;

// 各种重用标识
static NSString *const tableCellIdentifier = @"tableCell";
static NSString *const collectionCellIdentifier = @"collectionCell";
static NSString *const collectionHeaderIdentifier = @"collectionHeader";

@interface ViewController ()
<
UITableViewDataSource,
UITableViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate
>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UICollectionView *collectionView;

// 是否是点击 （这个属性是为了解决点击tableView的cell联动collectionView滑动，又重新影响cell的选中位置的bug）
@property (nonatomic, assign, getter=isTableSelected) BOOL tableSelected;
// collection布局
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // 设置navigationBar不透明
    self.navigationController.navigationBar.translucent = NO;
    // 防止系统为我们自动调整scrollView的insets
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // 默认值yes
    self.tableSelected = YES;
    
    self.tableView = [self getLeftTableView];
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:tableCellIdentifier];
    [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    self.collectionView = [self getRightCollectionView];
    
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:collectionCellIdentifier];
    
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:collectionHeaderIdentifier];
    
    
}

// 联动逻辑部分

#pragma mark -
#pragma 滑动右侧collectionView联动左侧table列表

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.tableSelected = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (!self.isTableSelected && [scrollView isEqual:self.collectionView]) {
        
        NSInteger contentSectionCount = tableViewCellCount - 1;
        // 获取当前有效的item的位置数组
        NSArray *indexPathArray = [_collectionView indexPathsForVisibleItems];
        // 获取当前最小的section是多少
        for (NSIndexPath *indexPath in indexPathArray) {
            if (contentSectionCount > indexPath.section) {
                contentSectionCount = indexPath.section;
            }
        }
        
        [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:contentSectionCount inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
   
    }

}

#pragma mark -
#pragma 点击左侧tableView联动右侧collectionView滑动

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.tableSelected = YES;
    
    // 获取滑动的某一个位置布局属性对象（直接使用scrollToIndexPath会看不见header）
    UICollectionViewLayoutAttributes *attributes = [_collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:indexPath.row]];
    // 当前位置的frame的y坐标减header的高度就是我们想要滑动的位置
    [_collectionView setContentOffset:CGPointMake(0, attributes.frame.origin.y - _flowLayout.headerReferenceSize.height) animated:YES];
    
}


// 下面是视图的基础创建，上面是联动的逻辑

#pragma mark - 
#pragma tableView创建

- (UITableView *)getLeftTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 100, CGRectGetHeight(self.view.bounds)) style:UITableViewStylePlain];
    tableView.rowHeight = 80.f;
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    
    return tableView;
}

#pragma mark -
#pragma collectionView创建

- (UICollectionView *)getRightCollectionView {
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    _flowLayout.headerReferenceSize = CGSizeMake(0, 60);
    _flowLayout.itemSize = CGSizeMake(80, 80);
    
    CGPoint origin = {_tableView.bounds.size.width, 0};
    CGSize size = {CGRectGetWidth(self.view.bounds) - origin.x, CGRectGetHeight(_tableView.frame)};
    CGRect frame = {origin, size};
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:_flowLayout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [self.view addSubview:collectionView];
    return collectionView;
}

#pragma mark -
#pragma UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tableViewCellCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableCellIdentifier];
    cell.textLabel.text = [NSString stringWithFormat:@"menu : %ld", indexPath.row];
    return cell;
}

#pragma mark -
#pragma UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return tableViewCellCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return collectionViewCellCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionCellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor cyanColor];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:collectionHeaderIdentifier forIndexPath:indexPath];
    headerView.backgroundColor = [UIColor redColor];
    return headerView;
}


@end
