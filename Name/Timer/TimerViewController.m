//
//  TimerViewController.m
//  Name
//
//  Created by hubin on 2023/3/24.
//

#import "TimerViewController.h"
#import "GCDTimer.h"
#import "ExProxy.h"

@interface TimerViewController ()

@property (nonatomic , strong) NSTimer * timer;

@property (nonatomic , strong) GCDTimer * gcdTimer;

@property (nonatomic , strong) NSDate * pauseStart;

@property (nonatomic , strong) NSDate * previousFireDate;

@property (nonatomic , assign) NSTimeInterval lastPauseTime;

@end

@implementation TimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SEL addTimer = @selector(addTimer);
    SEL addGCDTimer = @selector(addGCDTimer);
    
    [@[@"NSTimer",@"GCDTimer"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = [UIColor redColor];
        [btn setTitle:obj forState:UIControlStateNormal];
        btn.frame = CGRectMake((idx + 1) * 100 + idx * 20, 200, 100, 45);
        [btn addTarget:self action:idx == 0 ? addTimer : addGCDTimer
      forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }];
}

#pragma mark - NSTimer
- (void) addTimer {
    if(self.gcdTimer.timeState == GCDTimerRuning) {
        [self.gcdTimer suspendTimer];
    }
    
    if(self.timer) {
        [self resumeTimer];
    }else{
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:[ExProxy proxyWithTarget:self] selector:@selector(timerS) userInfo:nil repeats:YES];
    }
}

- (void) timerS {
    NSLog(@"每隔一秒执行一次：NSTimer方法");
}

- (void) pauseTimer{
    if(self.timer){
        self.pauseStart = [NSDate dateWithTimeIntervalSinceNow:0];
        self.previousFireDate = [self.timer fireDate];
        [self.timer setFireDate:[NSDate distantFuture]];
    }
}

- (void) resumeTimer{
    if(self.timer){
        float pauseTime = -1*[self.pauseStart  timeIntervalSinceNow];
        [self.timer setFireDate:[NSDate dateWithTimeInterval:pauseTime sinceDate:self.previousFireDate]];
    }
}

#pragma mark - GCDTimer
- (void) addGCDTimer {
    [self pauseTimer];
    __weak typeof(self) weakSelf = self;
    switch (self.gcdTimer.timeState) {
        case GCDTimerNone:
        case GCDTimerEnd:
        {
            [self.gcdTimer countDownWithNSTimeInterval:10 completeBlock:^(NSInteger day, NSInteger hour, NSInteger minute, NSInteger second) {
                weakSelf.lastPauseTime = second;
                NSLog(@"%zd-%zd-%zd-%zd",day,hour,minute,second);
            }];
        }
            break;
        case GCDTimerSuspend:
        {
            [self.gcdTimer activateTimer];
        }
            break;
        case GCDTimerRuning:
            break;
        default:
            break;
    }
}

- (GCDTimer *)gcdTimer {
    if(!_gcdTimer) {
        _gcdTimer = [[GCDTimer alloc] init];
    }
    return _gcdTimer;
}

#pragma mark - dealloc
- (void)dealloc{
    [self.timer invalidate];
    [self.gcdTimer destoryTimer];
}

@end
