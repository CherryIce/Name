//
//  ExampleViewController.h
//  Name
//
//  Created by hubin on 2023/3/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExampleViewController : UIViewController

//无返回值 无参数
@property (nonatomic, copy) void(^callback)(void);

//无返回值 有参数
@property (nonatomic , copy) void(^loadVideoProgressCallBack)(CGFloat progress);

//有返回值 无参数
@property (nonatomic,copy) NSArray *(^dataReceiver)(void);

//有返回值 有参数
@property (nonatomic, copy) int(^add)(int p1,int p2);

//
- (void)noParamsNoReturn:(void(^)(void))call;

//
- (void)noParamsHaveReturn:(void(^)(CGFloat progress))call;

//
- (void)haveParamsNoReturn:(NSArray *(^)(void))call;

//
- (void)haveParamsHaveReturn:(int(^)(int p1,int p2))call;

@end

NS_ASSUME_NONNULL_END
