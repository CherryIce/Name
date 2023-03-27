//
//  ExampleViewController.m
//  Name
//
//  Created by hubin on 2023/3/9.
//

#import "ExampleViewController.h"

@interface ExampleViewController ()
{
    int sum;
}

@property (nonatomic , copy) NSArray * receiverData;


@end

@implementation ExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 150, 150, 60);
    btn.backgroundColor = [UIColor brownColor];
    [btn setTitle:@"Use Block" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(doAll) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)noParamsNoReturn:(void (^)(void))call {
    self.callback = call;
}

- (void)noParamsHaveReturn:(void (^)(CGFloat))call {
    self.loadVideoProgressCallBack = call;
}

- (void)haveParamsNoReturn:(NSArray *(^)(void))call {
    self.dataReceiver = call;
}

- (void)haveParamsHaveReturn:(int (^)(int, int))call {
    self.add = call;
}

- (void) doAll {
    NSLog(@"ExampleViewController给ViewController传递了一个自己消失后随便它自己做操作的方法");
    if(self.callback) self.callback();
    
    NSLog(@"ExampleViewController给ViewController传递了一个进度：2.0");
    if(self.loadVideoProgressCallBack) self.loadVideoProgressCallBack(2.0);
    
    NSLog(@"ViewController给ExampleViewController传递了一个数组数据");
    if(self.dataReceiver) self.receiverData = self.dataReceiver();
    //当然这个block也可以只在本页面实现 这里只是举例 如果你想要反向传值 你也可以在下一个页面实现 这都随便 具体情况看实际开发
    NSLog(@"%@",self.receiverData);
    
    NSLog(@"ViewController给ExampleViewController传递了一个两个数之和");
    if(self.add) sum = self.add(3,4);
    //这个block跟上一个同理 你就传两个参数 剩下的你想自己处理开始交给别的页面处理都随便
    NSLog(@"%d",sum);
//    [self.navigationController popViewControllerAnimated:YES];
}

@end
