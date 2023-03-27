//
//  ThreadViewController.m
//  Name
//
//  Created by hubin on 2023/3/24.
//

#import "ThreadViewController.h"
#import "GCDTimer.h"

@interface ThreadViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic , strong) UITableView * tableView;

@end

@implementation ThreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.tableView reloadData];
}

//1、创建 selector方法最多只能接收一个参数，写的objcet就是传的参数
- (void)createNSThreadTest{
    NSString *threadName1 = @"NSThread1";
    NSString *threadName2 = @"NSThread2";
    NSString *threadName3 = @"NSThread3";
    NSString *threadNameMain = @"NSThreadMain";
    
    //方式一：初始化方式，需要手动启动
    NSThread *thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(doSomething:) object:threadName1];
    thread1.name = @"thread1";
    [thread1 start];
    
    //方式二：构造器方式，自动启动
    [NSThread detachNewThreadSelector:@selector(doSomething:) toTarget:self withObject:threadName2];
    
    //方式三：performSelector...方法创建子线程
    [self performSelectorInBackground:@selector(doSomething:) withObject:threadName3];
    
    //方式四:performSelector...方法创建主线程
    [self performSelectorOnMainThread:@selector(doSomething:) withObject:threadNameMain waitUntilDone:YES];
    
}

- (void) doSomething:(id) object {
    NSLog(@"------------%@",object);
}

//onceToken是静态变量，具有唯一性
//dispatch_once的底层会进行加锁来保证block执行的唯一性
//如果任务没有执行过，会将任务进行加锁，如果在当前任务执行期间，有其他任务进来，会进入无限次等待，原因是当前任务已经获取了锁，进行了加锁，其他任务是无法获取锁的。
- (void) testOnce{
    /*
     dispatch_once保证在App运行期间，block中的代码只执行一次
     应用场景：单例、method-Swizzling在
     */
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //创建单例、method swizzled或其他任务
        NSLog(@"____创建单例______");
    });
    NSLog(@"<dispatch_once里面只执行一次>");
}

//
- (void) testAfter {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"--------2s后输出-----------");
    });
}

//
- (void) testGCDTimer {
    [[[GCDTimer alloc] init] countDownWithNSTimeInterval:59 completeBlock:^(NSInteger day, NSInteger hour, NSInteger minute, NSInteger second) {
        NSLog(@"-----------倒计时---------%zd",second);
    }];
}

/*
 应用场景：同步当锁, 控制GCD最大并发数
 - dispatch_semaphore_create()：创建信号量
 - dispatch_semaphore_wait()：等待（减少）信号量，信号量减1。
 当信号量<0时会阻塞当前线程，根据传入的等待时间决定接下来的操作——
 如果永久等待将等到有信号（信号量>=0）才可以执行下去
 - dispatch_semaphore_signal()：递增信号量，信号量加1。当信号量>= 0 会执行dispatch_semaphore_wait中等待的任务
 */
- (void) testSemaphore {
    
    dispatch_queue_t queue = dispatch_queue_create("TestSemaphore", DISPATCH_QUEUE_CONCURRENT);
    
    for (int i = 0; i < 5; i++) {
        dispatch_async(queue, ^{
            NSLog(@"没锁之前：当前 - %d", i);
        });
    }
    
    //利用信号量来改写
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    
    for (int i = 0; i < 5; i++) {
        dispatch_async(queue, ^{
//            [NSThread currentThread];
            NSLog(@"锁之后： 当前 - %d", i);
            //当前信号量+1
            dispatch_semaphore_signal(sem);
        });
        //当前信号量-1
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
}

- (void) testBarrier {
    dispatch_queue_t queue = dispatch_queue_create("TestBarrier", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"_______延迟2s的任务1_________");
    });
    NSLog(@"_________第一次结束_________");
    
    //栅栏函数的作用是将队列中的任务进行分组，这里使用同步栅栏函数dispatch_barrier_sync，分割了栅栏上下的任务
    dispatch_barrier_sync(queue, ^{
        sleep(1);
        NSLog(@"_________延迟1s的栅栏任务_________");
    });
    NSLog(@"_________栅栏结束_________");
    
    dispatch_async(queue, ^{
        NSLog(@"_________不延迟的任务2_________");
    });
    NSLog(@"_________第二次结束_________");
}

/*
 dispatch_group_t：调度组将任务分组执行，能监听任务组完成，并设置等待时间
 应用场景：多个接口请求之后刷新页面
 */
- (void) testGroup {
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    dispatch_group_async(group, queue, ^{
        sleep(2);
        NSLog(@">>>>>>>>>>>请求一完成");
    });
    
    dispatch_group_async(group, queue, ^{
        sleep(1);
        NSLog(@">>>>>>>>>>>请求二完成");
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@">>>>>>>>>>>刷新页面");
    });
}

/*
 dispatch_group_enter和dispatch_group_leave成对出现，使进出组的逻辑更加清晰
 */
- (void) testGroupEnterAndLeave {
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"+++++++++++请求一完成");
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"+++++++++++请求二完成");
        dispatch_group_leave(group);
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"+++++++++++刷新界面");
    });
}

/*
 在GCD中只能使用信号量来设置并发数
 而NSOperation轻易就能设置并发数
 通过设置maxConcurrentOperationCount来控制单次出队列去执行的任务数
 */
- (void)testOperationMaxCount{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"Felix";
    queue.maxConcurrentOperationCount = 2;//这是单次执行的数量 而不是总数量
    
    for (int i = 0; i < 5; i++) {
        [queue addOperationWithBlock:^{ // 一个任务
            [NSThread sleepForTimeInterval:1];
            NSLog(@"queue do %d",i);
        }];
    }
}

//添加依赖：后执行的依赖先执行的
- (void)testOperationDependency{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSBlockOperation *bo1 = [NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@" first step : 请求token ");
    }];
    
    NSBlockOperation *bo2 = [NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:3];
        NSLog(@" second step : 拿着token,请求数据1 ");
    }];
    
    NSBlockOperation *bo3 = [NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:2.5];
        NSLog(@" third step : 拿着数据1,请求数据2 ");
    }];
    
    [bo2 addDependency:bo1];
    [bo3 addDependency:bo2];
    
    [queue addOperations:@[bo1,bo2,bo3] waitUntilFinished:YES];
    
    NSLog(@" final step : 终于执行完了?可以刷新页面干正事了 ");
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //通过方法名找到方法
    NSString * selStr = [self methods][indexPath.section][indexPath.item];
    SEL selector = NSSelectorFromString(selStr);
    IMP imp = [self methodForSelector:selector];
    //通过imp指针执行方法
    void (*func)(id, SEL) = (void *)imp;
    func(self, selector);
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self sectionsData] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray * rows = [self rowsData][section];
    return [rows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    NSArray * rows = [self rowsData][indexPath.section];
    cell.textLabel.text = rows[indexPath.item];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self sectionsData][section];
}

- (NSArray *) sectionsData {
    return @[@"NSThread",@"GCD",@"NSOperation"];
}

- (NSArray *) rowsData {
    return @[
        @[@"NSThread"],
        @[@"dispatch_once单例",
          @"dispatch_after延迟执行",
          @"dispatch_source_t主要用于计时操作",
          @"dispatch_semaphore_t信号量",
          @"栅栏函数",
          @"dispatch_group",
          @"dispatch_group_enter和dispatch_group_leave"],
        @[@"NSOperation",@"NSOperation添加依赖"]];
}

- (NSArray *) methods {
    return @[
        @[@"createNSThreadTest"],
        @[@"testOnce",
          @"testAfter",
          @"testGCDTimer",
          @"testSemaphore",
          @"testBarrier",
          @"testGroup",
          @"testGroupEnterAndLeave"],
        @[@"testOperationMaxCount",@"testOperationDependency"]];
}

- (UITableView *)tableView {
    if(!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
        _tableView.rowHeight = 50;
        _tableView.sectionHeaderHeight = 30;
        _tableView.sectionFooterHeight = 1;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

@end
