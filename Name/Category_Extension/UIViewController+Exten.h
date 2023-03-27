//
//  UIViewController+Exten.h
//  Name
//
//  Created by hubin on 2023/3/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController ()

//这是可以理解为private类型的方法；只可以在该类@implementation内部调用；对外部不可见
- (void) extensionFunc;

@end

NS_ASSUME_NONNULL_END
