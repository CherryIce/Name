//
//  KVOViewController.m
//  Name
//
//  Created by hubin on 2023/3/24.
//

#import "KVOViewController.h"
#import "Man.h"

typedef NS_ENUM(NSUInteger, HandleType) {
    HandleTypeNone = 0,
    HandleTypeNormal = 1,
    HandleTypeObject = 2,
    HandleTypeAll = 3
};

@interface KVOViewController ()

@property (nonatomic , copy) NSString * kvoName;

@property (nonatomic , strong) Man * man;

@property (nonatomic , strong) People * people;

@property (nonatomic , assign) HandleType handleType;

@end

@implementation KVOViewController

//- (void)setKvoName:(NSString *)kvoName {
//    _kvoName = kvoName;
//}

- (Man *)man {
    if (!_man) {
        _man = [[Man alloc] init];
    }
    return _man;
}

- (People *)people {
    if (!_people) {
        _people = [[People alloc] init];
    }
    return _people;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    SEL normalKVO = @selector(normalKVO);
    SEL objectKVO = @selector(objectKVO);
    
    [@[@"NormalKVO",@"ObjectKVO"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = [UIColor redColor];
        [btn setTitle:obj forState:UIControlStateNormal];
        btn.frame = CGRectMake((idx + 1) * 100 + idx * 20, 200, 100, 45);
        [btn addTarget:self action:idx == 0 ? normalKVO : objectKVO
      forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }];
}

/**
 一般来说我们用 forKeyPath的值来区分监听对象
 如果forKeyPath相同的情况就要用设置context来区分监听对象
 */
- (void) normalKVO {
    
    _handleType = _handleType == (HandleTypeObject|HandleTypeAll) ? HandleTypeAll : HandleTypeNormal;
    
    self.kvoName = @"changeValue1";
    [self addObserver:self forKeyPath:@"kvoName" options:NSKeyValueObservingOptionNew context:NULL];
    
    [self method1];
//    [self method2];
//    [self method3];
}

//通过set方法监听变化 这就是kvo的本质
- (void) method1 {
    //方式1:
    self.kvoName = @"changeValue2";
}

//通过KVC监听变化 这也是kvo的本质
- (void) method2 {
    //方式2:KVC
    [self setValue:@"changeValue2" forKey:@"kvoName"];
}

//通过加写KVO的 willChangeValueForKey didChangeValueForKey 来监听对象 这是直接调用了KVO的方法
- (void) method3 {
    //方式3:
    [self willChangeValueForKey:@"kvoName"];
    _kvoName = @"changeValue2";
    [self didChangeValueForKey:@"kvoName"];
}

static void *PeopleNameContext = &PeopleNameContext;
static void *ManNameContext = &ManNameContext;
- (void) objectKVO {
    
    _handleType = _handleType == (HandleTypeNormal|HandleTypeAll) ? HandleTypeAll : HandleTypeObject;
    
    //观察man的name属性
    self.man.name = @"xiao ming";
//    [self addObserver:self forKeyPath:@"man.name" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.man addObserver:self
               forKeyPath:@"name"
                  options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                  context:ManNameContext];
    self.man.name = @"xiao hong";
    
    //观察people的name属性
    self.people.name = @"people name 1";
    [self.people addObserver:self
                  forKeyPath:@"name"
                     options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                     context:PeopleNameContext];
    self.people.name = @"people name 2";
    
    //观察man中的评论变化
    [self.man addObserver:self
               forKeyPath:@"comments"
                  options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                  context:ManNameContext];
    //不要这么做，会崩溃 [<__NSArrayM 0x6000030c5860> addObserver:forKeyPath:options:context:] is not supported.
//    [self.man.comments addObject:@"xxxx"];
    [[self.man mutableArrayValueForKey:@"comments"] addObject:@"1"];
    [[self.man mutableArrayValueForKey:@"comments"] addObject:@"2"];
    [[self.man mutableArrayValueForKey:@"comments"] removeObject:@"1"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if(context == ManNameContext) {
        if ([keyPath isEqualToString:@"name"]) {
            NSLog(@"\n We see a change in the value = newValue : %@",change);
        }else{
            NSLog(@"\n We see a change in the value = newValue : %@",change);
        }
    }else if (context == PeopleNameContext) {
        if ([keyPath isEqualToString:@"name"]) {
            NSLog(@"\n We see a change in the value = newValue : %@",change);
        }
    }else{
        if ([keyPath isEqualToString:@"kvoName"]) {
            NSLog(@"\n We see a change in the value = newValue : %@",change);
        }
    }
}

#pragma mark - dealloc
- (void)dealloc{
    //
    switch (_handleType) {
        case HandleTypeNone:
            break;
        case HandleTypeNormal:{
            [self removeObserver:self forKeyPath:@"kvoName"];
        }
            break;
        case HandleTypeObject:{
            [self.man removeObserver:self forKeyPath:@"name"];
            [self.man removeObserver:self forKeyPath:@"comments"];
            [self.people removeObserver:self forKeyPath:@"name"];
        }
            break;
        case HandleTypeAll:{
            [self.man removeObserver:self forKeyPath:@"name"];
            [self.man removeObserver:self forKeyPath:@"comments"];
            [self.people removeObserver:self forKeyPath:@"name"];
            [self removeObserver:self forKeyPath:@"kvoName"];
        }
            break;
        default:
            break;
    }
    
//    [self removeObserver:self forKeyPath:@"man.name"];
}

@end
