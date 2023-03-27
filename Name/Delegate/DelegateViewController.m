//
//  DelegateViewController.m
//  Name
//
//  Created by hubin on 2023/3/24.
//

#import "DelegateViewController.h"
#import "ListTableViewCell.h"
#import "SkillTableViewCell.h"

@interface DelegateViewController ()
<UITableViewDelegate,UITableViewDataSource,
ListTableViewCellDelegate,SkillCellEventDelegate>

@property (nonatomic , strong) UITableView * tableView;

@property (nonatomic , strong) NSMutableArray * datas;

@end

@implementation DelegateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    SkillDataItem * item1 = [[SkillDataItem alloc] init];
    item1.title = @"常规用法";
    item1.value = @"使用场景都可以";
    [self.datas addObject:item1];
    
    SkillDataItem * item2 = [[SkillDataItem alloc] init];
    item2.cellClass = [SkillTableViewCell class];
    item2.title = @"封装用法";
    item2.value = @"使用:多个不同Cell数据源类似或则操作相近,如IM消息";
    [self.datas addObject:item2];
    
    [self.tableView reloadData];
}


#pragma  mark - ListTableViewCellDelegate
- (void)clickFinishAndReturnSome:(id)someValue {
    NSLog(@"______normal______:%@",someValue);
}

#pragma mark - SkillCellEventDelegate
-  (void)buttonClick:(SkillDataItem *)data  {
    NSLog(@"______packet______:%@",data);
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SkillDataItem * item = self.datas[indexPath.item];
    if(item.cellClass) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(item.cellClass) forIndexPath:indexPath];
        [(id<SkillCellDataDelegate>)cell setData:item delegate:self];
        return cell;
    }
    
    ListTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ListTableViewCell class]) forIndexPath:indexPath];
    if(!cell) {
        cell = [[ListTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NSStringFromClass([ListTableViewCell class])];
    }
    cell.delegate = self;
    [cell.button setTitle:item.value forState:UIControlStateNormal];
    return cell;
}

- (UITableView *)tableView {
    if(!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        [_tableView registerClass:[ListTableViewCell class] forCellReuseIdentifier:NSStringFromClass([ListTableViewCell class])];
        [_tableView registerClass:[SkillTableViewCell class] forCellReuseIdentifier:NSStringFromClass([SkillTableViewCell class])];
        _tableView.rowHeight = 50;
        _tableView.sectionHeaderHeight = 10;
        _tableView.sectionFooterHeight = 1;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (NSMutableArray *)datas {
    if(!_datas) {
        _datas = [NSMutableArray array];
    }
    return _datas;
}

@end
