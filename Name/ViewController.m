//
//  ViewController.m
//  Name
//
//  Created by hubin on 2023/3/4.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic , strong) UITableView * tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"*****runloop*****:\n%@\n",[NSRunLoop currentRunLoop]);
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController * ctl = [[NSClassFromString([self ctls][indexPath.item]) alloc] init];
    ctl.title = [self ctls][indexPath.item];
    [self.navigationController pushViewController:ctl animated:true];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self rowsData] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    cell.textLabel.text = [self rowsData][indexPath.item];
    return cell;
}

- (NSArray *) rowsData {
    return @[@"Block",
             @"Delegate",
             @"Notification",
             @"KVO_KVC",
             @"Category_Extension",
             @"timer",
             @"NSProxy",
             @"Thread",
             @"Lock",
             @"Runtime",
             @"RunLoop"];
}

- (NSArray *) ctls {
    return @[@"BlockViewController",
             @"DelegateViewController",
             @"NotificationViewController",
             @"KVOViewController",
             @"CategoryViewController",
             @"TimerViewController",
             @"TimerViewController",
             @"ThreadViewController",
             @"LockViewController",
             @"RuntimeViewController",
             @"RunLoopViewController"];
}

- (UITableView *)tableView {
    if(!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
        _tableView.rowHeight = 50;
        _tableView.sectionHeaderHeight = 10;
        _tableView.sectionFooterHeight = 1;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

@end
