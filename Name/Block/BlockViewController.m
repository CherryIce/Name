//
//  BlockViewController.m
//  Name
//
//  Created by hubin on 2023/3/24.
//

#import "BlockViewController.h"
#import "ExampleViewController.h"

@interface BlockViewController ()

@property (nonatomic , strong) UIImageView * imageView;

@end

@implementation BlockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    SEL NormalBlock = @selector(normalBlock);
    SEL ExpandBlock = @selector(expandBlock);
    [@[@"NormalBlock",@"ExpandBlock"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = [UIColor redColor];
        [btn setTitle:obj forState:UIControlStateNormal];
        btn.frame = CGRectMake( idx* 120 + (idx + 1) * 20, 150, 120, 45);
        [btn addTarget:self
                action:idx == 0 ? NormalBlock : ExpandBlock
      forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }];
}

//一般项目里的常用block
- (void) normalBlock {
    ExampleViewController * example = [ExampleViewController new];
    [example haveParamsNoReturn:^NSArray *{
        return @[@"1",@"2",@"3",@"4"];
    }];
    __weak typeof(self) weakSelf = self;
    [example noParamsHaveReturn:^(CGFloat progress) {
        __strong typeof(weakSelf) strongSelf = weakSelf; 
        NSLog(@"%@",[NSString stringWithFormat:@"%.f",progress]);
    }];
    __weak typeof(example) weakExample = example;
    [example noParamsNoReturn:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"2s后输出");
        });
        NSLog(@"do something");
    }];
    [example haveParamsHaveReturn:^int(int p1, int p2) {
        return p1+p2;
    }];
    [self.navigationController pushViewController:example animated:true];
}

//block探索
- (void) expandBlock {
    /**
     Block只捕获Block中会用到的变量。
     自动变量是以值传递方式传递到Block的构造函数里面去的。
     由于只捕获了自动变量的值，并非内存地址, block内外是2个完全不同的变量, 只是恰好那个时刻的值一样，修改block内部的值不能影响到block外部的值,
     于是编译器提前告诉开发者, 采用了编译报错的方式.   所以Block内部不能改变自动变量的值。
     */
    
    /**
     首先全局变量global_value和静态全局变量static_global_value的值增加，它们没有被Block捕获进去
     这一点很好理解，因为是全局的，作用域很广，在Block里面进行++操作，Block结束之后，它们的值依旧可以得以保存下来
     
     在__main_block_impl_0中，可以看到静态变量static_value和自动变量value，被Block从外面捕获进来，
     成为__main_block_impl_0这个结构体的成员变量了
     
     自动变量val虽然被捕获进来了，但是是用__cself->val来访问的。
     Block仅仅捕获了val的值，并没有捕获val的内存地址。
     所以在__main_block_func_0这个函数中即使我们重写这个自动变量value的值，依旧没法去改变Block外面自动变量value的值
     */
    int other = 999;
    __block int value = 1;
    static int static_value = 2;
    void (^changeValue)(void) = ^ {
        NSLog(@"_______block内other的地址：%p",&other);
        value += 1;
        static_value += 1;
        global_value += 1;
        static_global_value += 1;
        NSLog(@"block中局部变量--------%d,\n 地址:%p",value,&value);
        NSLog(@"block中局部静态变量--------%d,\n 地址:%p",static_value,&static_value);
        NSLog(@"block中全局变量--------%d,\n 地址:%p",global_value,&global_value);
        NSLog(@"block中全局静态变量--------%d,\n 地址:%p",static_global_value,&static_global_value);
    };
    value += 1;
    static_value += 1;
    global_value += 1;
    static_global_value += 1;
    NSLog(@"block外局部变量--------%d,\n 地址:%p",value,&value);
    NSLog(@"block外局部静态变量--------%d,\n 地址:%p",static_value,&static_value);
    NSLog(@"block外全局变量--------%d,\n 地址:%p",global_value,&global_value);
    NSLog(@"block外全局静态变量--------%d,\n 地址:%p",static_global_value,&static_global_value);
    
    NSLog(@"_______block外other的地址：%p",&other);
    changeValue();
    
    NSLog(@"++++++ changeValue block的type ++++++%@",changeValue);
    NSLog(@"++++++ no change block的type ++++++%@",^{NSLog(@"no change block");});
    
    //当然这里只是基本数据类型 也可以换成对象类型 eg:NSNumber
    //参考：https://blog.csdn.net/u014600626/article/details/86570932
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString * urlStr = @"https://upload-images.jianshu.io/upload_images/4068785-624d055aecb4c9c5.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200";
        urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[[NSCharacterSet characterSetWithCharactersInString:@"#%^{}\"[]|\\<> "] invertedSet]];
        NSURL * url = [NSURL URLWithString:urlStr];
        NSData * imageData = [NSData dataWithContentsOfURL:url];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.imageView.image = [UIImage imageWithData:imageData];
        });
    });
}

- (UIImageView *)imageView {
    if(!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor brownColor];
        _imageView.frame = CGRectMake(0, 0, 300, 100);
        _imageView.center = self.view.center;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:_imageView];
    }
    return _imageView;
}

@end
