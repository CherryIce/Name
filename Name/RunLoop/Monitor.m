//
//  Monitor.m
//  Name
//
//  Created by hubin on 2023/3/26.
//

#import "Monitor.h"
#import "BSBacktraceLogger.h"

@interface Monitor ()
{
    CFRunLoopObserverRef runLoopObserver;
    
    int timeoutCounting;//超时计数
    
    dispatch_semaphore_t dispatchSemaphore; //信号量
    CFRunLoopActivity runLoopActivity; //RunLoop的状态
}

@end

@implementation Monitor

+ (instancetype)shareInstance {
    static id instance = nil;
    static dispatch_once_t dispatchOnce;
    dispatch_once(&dispatchOnce, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (void)beginMonitor {
    CFRunLoopObserverContext context = {
        0,
        (__bridge void *)(self),
        NULL,
        NULL
    }; //context是一个结构体 info参数会传到CFRunLoopObserverCreate的callout的info中.
    
    dispatchSemaphore = dispatch_semaphore_create(0);//建立信号量
    
    runLoopObserver = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, &runLoopObserverCallBack, &context);//参数分别是: 分配空间 状态枚举 是否循环调用observer 优先级 回调函数 结构体
    
    CFRunLoopAddObserver(CFRunLoopGetMain(), runLoopObserver, kCFRunLoopCommonModes);//添加到主线程的RunLoop
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{//开启监控子线程
        
        while (YES) {//loop
            
            long semphoreWait = dispatch_semaphore_wait(self->dispatchSemaphore, dispatch_time(DISPATCH_TIME_NOW, 0.25*NSEC_PER_SEC));
            //信号量为0的时候会等待0.25秒再执行后面的代码,即0.25秒为超时时0.
            //若是信号量为0等待超时后该方法就返回非零,不然返回0,也就是说信号量在观察到RunLoop变化的时候会执行callout信号量+1,而后该方法-1返回0,继续执行下面方法.另外,0.25秒timeout的阻塞过程当中,若是信号量因状态改变增量,就直接返回0执行后面代码.
            
            if (semphoreWait == 0) {
                self->timeoutCounting = 0;
            }else{
                if (!self->runLoopObserver) {
                    self->dispatchSemaphore = 0;
                    self->timeoutCounting = 0;
                    self->runLoopActivity = 0;
                }

                if (self->runLoopActivity == kCFRunLoopBeforeSources || self->runLoopActivity == kCFRunLoopAfterWaiting) {//RunLoop两个状态,若是触发即将进入source0状态后一直没有进入下一个BeforeWaiting状态,那说明方法执行时间过长. 而后是AfterWaiting也就是即将唤醒状态,若是这个状态持续时间太久,说明调用mach_msg 等待接受mach_port的消息时间过长而没法进入下一状态.他们的表现就是阻塞主线程,形成卡顿,经过监控它们来监控卡顿.
                    if (++self->timeoutCounting<1) {//超过1s上报堆栈信息 若是以为长的话,能够把上面的时间改为纳秒、毫秒等
                        continue;
                    }
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{//再开启一个子线程来上报堆栈信息
                        NSLog(@"<<<<<<<<<<<<<耗时线程堆栈信息>>>>>>>>>>>>>>");
                        BSLOG_MAIN  // 打印主线程调用栈， BSLOG 打印当前线程，BSLOG_ALL 打印所有线程
                        // 调用 [BSBacktraceLogger bs_backtraceOfCurrentThread] 这一系列的方法可以获取字符串，然后选择上传服务器或者其他处理。
                    });
                }
            }
        }
    });
}

- (void)endMonitor {
    if (!runLoopObserver) {
        return;
    }
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), runLoopObserver, kCFRunLoopCommonModes);
    CFRelease(runLoopObserver);
    runLoopObserver = NULL;
}

static void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info){
    Monitor *monitor = (__bridge Monitor *)(info);//桥接self
    monitor->runLoopActivity = activity;
    dispatch_semaphore_signal(monitor->dispatchSemaphore);//信号量+1
}

@end
