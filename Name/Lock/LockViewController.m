//
//  LockViewController.m
//  Name
//
//  Created by hubin on 2023/3/25.
//

#import "LockViewController.h"
// 导入头文件
#import <pthread.h>

@interface LockViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    // 全局声明互斥锁
    pthread_mutex_t _lock;
}

@property (nonatomic , strong) UITableView * tableView;

@end

@implementation LockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /***
     自旋锁与互斥锁的区别在于： 互斥锁如果发现资源已经被占用了，也就是发现已经被上锁了，就会进入睡眠状态，但自旋锁不会睡眠，而是以忙等待的状态一直不停的查看是否已经被释放了。
     重点在于忙等待，不停的进行查看。
     自旋锁避免了线程上下文调度开销，因此对于线程只会阻塞很短时间的场合是有效的，所以性能是很高的。
     自从OSSpinLock出现调度的优先级反转安全问题，在iOS10之后就被废弃了。
     在OSSpinLock被弃用后，其替代方案是内部封装了os_unfair_lock，而os_unfair_lock在加锁时会处于休眠状态，而不是自旋锁的忙等状态
     */
    
    [self.tableView reloadData];
}

/**
 通过查看源码可知@synchorized是一把递归互斥锁，可重入，未释放可再次加锁
 可重入的表现为同一个线程可以重复锁；多个线程可以重复加锁
 通过链表结构实现了递归的特点，每个线程的缓存中均对锁对象进行存储，通过lockCount、threadCount的记录可以判断递归的次数
 锁并不一定是self，要知道锁的生命周期与锁住的内容的生命周期，合理选择锁。最好生命周期相同
 由于底层中链表查询、缓存的查找以及递归，是非常耗内存以及性能的，导致性能低，所以在前文中，该锁的排名在最后
 但是目前该锁的使用频率仍然很高，主要是因为方便简单，且不用解锁
 不能使用非OC对象作为加锁对象，因为其object的参数应当为id
 */
- (void) synchronizedLock {
    for (int i = 0; i < 10; i++) {
        NSObject * object = [[NSObject alloc] init];
        //在@synchronized (object)添加断点，运行至断点位置选择 Xcode 菜单栏的Debug > Debug Workflow > Always Show Disassembly，可以看到其汇编代码
        @synchronized (object) {
            
        }
    }
}

/**
 使用起来很简单，就是通过lock和unlock进行加锁减锁，在其内部的代码就是线程安全的代码
 它只是单纯的互斥锁，不是递归锁，所以下面代码会出现一直等待的现象
 遵循了NSLocking协议，底层通过pthread_mutex实现的。
 */
- (void) addNSLock {
    NSLock *lock = [[NSLock alloc] init];
    for (int i= 0; i<3; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            static void (^testMethod)(int);
            testMethod = ^(int value){
                [lock lock];
                if (value > 0) {
                    NSLog(@" NSLock current value = %d",value);
                    testMethod(value - 1);
                }
            };
            testMethod(10);
            [lock unlock];
        });
    }
}

/***
 递归锁也是一种互斥锁，但是它用在递归函数的线程安全中，不解锁可以再次加锁，带有递归性质的互斥锁
 使用上和NSLock一样，它只比NSLock多了一个就是可以用在递归函数中
 
 为什么互斥锁会在递归函数中死锁？
 因为加锁之后还没有解锁就进入下一个循环再去加锁，就会死锁了。
 死锁是因为线程会等待锁的释放而进行休眠状态，但是这个锁又不可能被释放，就会一直处于等待状态，无法执行下去，一直处于死锁状态。
 */
- (void) addNSRecursiveLock {
    NSRecursiveLock *lock = [[NSRecursiveLock alloc] init];
    for (int i= 0; i<3; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            static void (^testMethod)(int);
            testMethod = ^(int value){
                [lock lock];
                if (value > 0) {
                    NSLog(@" NSRecursiveLock current value = %d",value);
                    testMethod(value - 1);
                }
            };
            testMethod(10);
            [lock unlock];
        });
    }
}

- (void) addNSConditionLock {
    
    NSCondition * testCondition = [[NSCondition alloc] init];
    __block NSUInteger ticketCount = 0;
    
    //创建生产-消费者
    for (int i = 0; i < 10; i++) {
        // 生产者
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [testCondition lock]; // 操作的多线程影响
            ticketCount += 1;
            NSLog(@"生产一个 现有 count %zd",ticketCount);
            [testCondition signal]; // 发送信号
            [testCondition unlock];
        });
        
        // 消费者
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [testCondition lock];  // 操作的多线程影响
            if (ticketCount == 0) {
                NSLog(@"等待 count %zd",ticketCount);
                [testCondition wait]; // 线程等待
            }
            //注意消费行为，要在等待条件判断之后
            ticketCount -= 1;
            NSLog(@"消费一个 还剩 count %zd ",ticketCount);
            [testCondition unlock];
        });
    }
    
    //初始化状态为2
    NSConditionLock *conditionLock = [[NSConditionLock alloc] initWithCondition:2];
    
    //条件为1时执行加锁，并且解锁时将条件设置为0
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [conditionLock lockWhenCondition:1]; // conditoion = 1 内部 Condition 匹配
        NSLog(@"线程 1");
        [conditionLock unlockWithCondition:0]; // 解锁并把conditoion设置为0
    });
    
    //条件为2时可执行加锁，并且解锁时将条件设置为1
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [conditionLock lockWhenCondition:2]; // conditoion = 2 内部 Condition 匹配
        NSLog(@"线程 2");
        [conditionLock unlockWithCondition:1]; // 解锁并把conditoion设置为1
    });
    
    //就是普通的锁，不加任何条件,任何时候都可能来
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //        sleep(2);
        [conditionLock lock];
        NSLog(@"线程 3");
        [conditionLock unlock];
    });
    
    //如果不加任何条件，会发现3要比2要快，所以猜测条件加锁要比条件不加锁更消耗性能
}

- (void) testSemaphore {
    //控制单次最大执行2个
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(2);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for (int i = 0; i < 10; i++)
    {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_async(queue, ^{
            NSLog(@"<><><><><>>><><><><><><>><<><>><>>>%i",i);
            sleep(2);
            dispatch_semaphore_signal(semaphore);
        });
    }
}

- (void) readAndWrite {
    dispatch_queue_t safeQueue = dispatch_queue_create("", DISPATCH_QUEUE_CONCURRENT);
    
    __block NSUInteger ticketCount = 0;
    
    //读取
    dispatch_async(dispatch_queue_create("", DISPATCH_QUEUE_CONCURRENT), ^{
        dispatch_sync(safeQueue, ^{
            NSLog(@"读取：%ld",ticketCount);
        });
    });
    
    for (int i = 0; i < 10; i ++) {
        //写入
        dispatch_barrier_async(safeQueue, ^{
            sleep(2);
            ticketCount ++;
            NSLog(@"写入：%ld",ticketCount);
            
        });
    }
    
    //读取
    dispatch_async(dispatch_queue_create("", DISPATCH_QUEUE_CONCURRENT), ^{
        dispatch_sync(safeQueue, ^{
            NSLog(@"====读取：%ld",ticketCount);
        });
    });
}

/**
 pthread_mutex就是互斥锁本身，NSLock、NSRecursiveLock以及NSCondition都是基于它实现的
 当锁被占用，其他线程申请锁时，不会一直忙等待，而是阻塞线程并睡眠。
 */
- (void) test_pthread_mutex {
    
    for (int i = 0 ; i < 10; i++) {
        dispatch_async(dispatch_queue_create("", DISPATCH_QUEUE_CONCURRENT), ^{
            // 初始化互斥锁
            pthread_mutex_init(&self->_lock, NULL);
            
            // 加锁
            pthread_mutex_lock(&self->_lock);
            
            // 这里做需要线程安全操作
            //{...code...}
            NSLog(@"+++++++++%d",i);
            
            // 解锁
            pthread_mutex_unlock(&self->_lock);
            
            //操作结束 释放锁
            pthread_mutex_destroy(&self->_lock);
        });
    }
}

- (void) test_OSSpinLock {
    //被放弃了
}

- (void) test_os_unfair_lock {
    if (@available(iOS 10.0, *)) {
        //        os_unfair_lock_t unfairLock;
        //        unfairLock = &(OS_UNFAIR_LOCK_INIT);
        //        os_unfair_lock_lock(unfairLock);
        //        os_unfair_lock_unlock(unfairLock);
    } else {
        // Fallback on earlier versions
    }
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
    return @[@"互斥锁",
             @"自旋锁"];
}

- (NSArray *) rowsData {
    return @[
        @[@"@synchronized",
          @"NSLock",
          @"递归锁NSRecursiveLock",
          @"条件锁NSConditionLock",
          @"semaphore",
          @"读写锁",
          @"pthread_mutex"],
        @[@"OSSpinLock已经在ios10以后废弃掉了",
          @"os_unfair_lock"]];
}

- (NSArray *) methods {
    return @[
        @[@"synchronizedLock",
          @"addNSLock",
          @"addNSRecursiveLock",
          @"addNSConditionLock",
          @"testSemaphore",
          @"readAndWrite",
          @"test_pthread_mutex"],
        @[@"test_OSSpinLock",
          @"test_os_unfair_lock"]];
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
