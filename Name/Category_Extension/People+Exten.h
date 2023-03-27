//
//  People+Exten.h
//  Name
//
//  Created by hubin on 2023/3/12.
//

#import "People.h"

NS_ASSUME_NONNULL_BEGIN

@interface People ()

@property (nonatomic, copy) NSString * nickName;

//这是可以理解为private类型的方法；只可以在该类@implementation内部调用；对外部不可见
- (void) extensionFunc;

@end

NS_ASSUME_NONNULL_END
