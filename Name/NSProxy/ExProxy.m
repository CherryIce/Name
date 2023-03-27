//
//  ExProxy.m
//  Name
//
//  Created by hubin on 2023/3/14.
//

#import "ExProxy.h"

@implementation ExProxy

+ (instancetype)proxyWithTarget:(id)target {
    ExProxy * proxy = [ExProxy alloc];
    proxy.target = target;
    return proxy;
}

// 调用时候就会返回方法签名
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.target methodSignatureForSelector:sel];
}

// 进行消息转发
- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:self.target];
}

@end
