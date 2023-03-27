//
//  GCDTimer.h
//  Name
//
//  Created by hubin on 2023/3/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GCDTimerState) {
    GCDTimerNone = 1,
    GCDTimerRuning = 2,
    GCDTimerSuspend = 3,
    GCDTimerEnd = 4 ,
};

@interface GCDTimer : NSObject

/**
 之所以不用+方法（类方法），而是用-方法（实例方法）来处理
 是因为类方法常驻内存的问题
 虽然类方法调用简单便捷，但是app启动开始就进行了内存分配，并且一直长存在内存中
 如果一个项目太多的类方法就会出现的程序启动变慢的问题 得不偿失
 */

//用NSDate日期倒计时
- (void)countDownWithStratDate:(NSDate *)startDate finishDate:(NSDate *)finishDate completeBlock:(void (^)(NSInteger day,NSInteger hour,NSInteger minute,NSInteger second))completeBlock;

//用时间戳倒计时
- (void)countDownWithStratTimeStamp:(long long)starTimeStamp finishTimeStamp:(long long)finishTimeStamp completeBlock:(void (^)(NSInteger day,NSInteger hour,NSInteger minute,NSInteger second))completeBlock;

//读秒
- (void)countDownWithNSTimeInterval:(NSTimeInterval)countDownSecond completeBlock:(void (^)(NSInteger day,NSInteger hour,NSInteger minute,NSInteger second))completeBlock;

//逐秒递增
- (void)addTimeWithNSTimeInterval:(NSTimeInterval)countDownSecond completeBlock:(void (^)(NSInteger day,NSInteger hour,NSInteger minute,NSInteger second))completeBlock;

//每秒走一次，回调block
- (void)countDownWithPER_SECBlock:(void (^)(void))PER_SECBlock;

//激活定时器
- (void)activateTimer;

//终止定时器
- (void)suspendTimer;

//销毁定时器
- (void)destoryTimer;

//定时器状态
@property (nonatomic , assign) GCDTimerState timeState;

- (NSDate *)dateWithLongLong:(long long)longlongValue;

@end

NS_ASSUME_NONNULL_END
