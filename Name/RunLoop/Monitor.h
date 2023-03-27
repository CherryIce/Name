//
//  Monitor.h
//  Name
//
//  Created by hubin on 2023/3/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Monitor : NSObject

+ (instancetype)shareInstance;

- (void)beginMonitor;

- (void)endMonitor;

@end

NS_ASSUME_NONNULL_END
