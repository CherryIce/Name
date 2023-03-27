//
//  RuntimeViewController.m
//  Name
//
//  Created by hubin on 2023/3/26.
//

#import "RuntimeViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>

#import "People.h"
#import "UIViewController+A.h"
#import "KVOViewController.h"

@interface RuntimeViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic , strong) UITableView * tableView;

@end

@implementation RuntimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.tableView reloadData];
}

//获取成员变量列表 class_copyIvarList
- (void) getIvarList {
    unsigned int count;
    
    Ivar *ivarList = class_copyIvarList([self class], &count);
    for(unsigned int i = 0; i < count; i++){
        Ivar myIvar = ivarList[i];
        const char *ivarName = ivar_getName(myIvar);
        NSString *ivarNameStr = [NSString stringWithUTF8String:ivarName];
        NSLog(@"成员变量：%d-%@",i,ivarNameStr);
    }
    free(ivarList);
}

//获取属性列表 class_copyPropertyList
- (void) getPropertyList {
    unsigned int count;
    
    objc_property_t *propertyList = class_copyPropertyList([self class], &count);
    for(unsigned int i = 0; i < count; i++){
        const char *propertyName = property_getName(propertyList[i]);
        NSString *propertyNameStr = [NSString stringWithUTF8String:propertyName];
        NSLog(@"属性：%d-%@",i,propertyNameStr);
    }
    free(propertyList);
}

//获取方法列表 class_copyMethodList
- (void) getMethodList {
    unsigned int count;
    
    Method *methodList = class_copyMethodList([self class], &count);
    for(unsigned int i = 0; i < count; i++){
        Method method = methodList[i];
        SEL _Nonnull aSelector = method_getName(method);
        NSString *methodName = NSStringFromSelector(aSelector);
        NSLog(@"方法名称：%@",methodName);
    }
    free(methodList);
}

//获取所遵循的协议列表
- (void) getProtocolList {
    unsigned int count;
    __unsafe_unretained Protocol **protocolList = class_copyProtocolList([self class], &count);
    for(unsigned int i = 0; i < count; i++){
        Protocol *myProtocol = protocolList[i];
        const char *protocolName = protocol_getName(myProtocol);
        NSString *protocolNameStr = [NSString stringWithUTF8String:protocolName];
        //NSSelectorFromString(protocolNameStr);
        NSLog(@"获取到的协议方法：%@",protocolNameStr);
    }
    free(protocolList);
}


- (void) changePrivateValue {
    People * p = [[People alloc] init];
    unsigned int count = 0;
    Ivar *ivar = class_copyIvarList(p.class, &count);
    for (int i = 0; i < count; i++) {
        Ivar tempIvar = ivar[i];
        const char *varName = ivar_getName(tempIvar);
        NSString *varNameString = [NSString stringWithUTF8String:varName];
        
        // 昵称是私有属性，也能修改
        if ([varNameString isEqualToString:@"_nickName"]) {
            object_setIvar(p, tempIvar, @"xiao ming's nickName");
        }
    }
    
    // 释放
    free(ivar);
    NSLog(@"______________%@",p);
    
    //通过runtime修改UITextField占位符属性
    /*
    //addTextFieldWithConfigurationHandler这个破东西有问题
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"title" message:@"message" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"input some";
        if (@available(iOS 13.0,*)) {
            Ivar ivar = class_getInstanceVariable([UITextField class], @"_placeholderLabel");
            UILabel *placeholderLabel = object_getIvar(textField, ivar);
            placeholderLabel.textColor = [UIColor redColor];
            placeholderLabel.font = [UIFont boldSystemFontOfSize:14];
        }else{
            [[UITextField new] setValue:[UIFont boldSystemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
        }
        textField.keyboardType = UIKeyboardTypePhonePad;
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField * textField = alert.textFields.firstObject;
        NSLog(@"-----------%@",textField.text);
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alert animated:true completion:nil];
     */
}

//分类添加属性
- (void) categoryAddIvar {
    self.testName = @"categoryAddIvar_TestName";
    NSLog(@"通过runtime添加的分类属性---%@",self.testName);
}

//swizzle交换方法 进行一些自定义操作 比如埋点记录页面点击 浏览时间等
- (void) funSwizzle {
    NSLog(@"查看UIViewController+A");
}

//字典转模型
- (void) dictionaryToModel {
    NSDictionary * d = @{@"name":@"runtime",
                         @"nickName":@"xiao ni",
                         @"age":@(18),
                         @"id":@(999)};
    People * p = [[People alloc] initModleWithDictionary:d];
    NSLog(@"字典转模型 p:%@",p);
}

//关于KVO
- (void) aboutKVO {
    KVOViewController * kvo = [[KVOViewController alloc] init];
    [self.navigationController pushViewController:kvo animated:YES];
}

//消息发送
- (void) messageSend {
    People * p = [[People alloc] init];
    //1
    [p performSelector:@selector(extensionFunc)];
    //2
    [p performSelector:NSSelectorFromString(@"extensionFunc")];
    //3
    objc_msgSend(p, @selector(extensionFunc));
    //4
    objc_msgSend(p, @selector(privateFunc:), @"hahahahhahaahha");
    //5
    Class pClassObj = NSClassFromString(@"People");
    objc_msgSend([pClassObj new], @selector(extensionFunc));
    //6
    NSLog(@"学习didSelectRowAtIndexPath里面用imp来调用");
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //通过方法名找到方法
    NSString * selStr = [self methods][indexPath.item];
    SEL selector = NSSelectorFromString(selStr);
    IMP imp = [self methodForSelector:selector];
    //通过imp指针执行方法
    void (*func)(id, SEL) = (void *)imp;
    func(self, selector);
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self rowsData] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    cell.textLabel.text = [self rowsData][indexPath.item];
    return cell;
}

- (NSArray *) rowsData {
    return @[@"获取成员变量列表",
             @"获取属性列表",
             @"获取方法列表",
             @"获取所遵循的协议列表",
             @"修改私有属性",
             @"给分类动态添加属性",
             @"Swizzle",
             @"字典转模型",
             @"KVO",
             @"消息传递和转发"];
}

- (NSArray *) methods {
    return @[@"getIvarList",
             @"getPropertyList",
             @"getMethodList",
             @"getProtocolList",
             @"changePrivateValue",
             @"categoryAddIvar",
             @"funSwizzle",
             @"dictionaryToModel",
             @"aboutKVO",
             @"messageSend"];
}

- (UITableView *)tableView {
    if(!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
        _tableView.rowHeight = 50;
        _tableView.sectionHeaderHeight = 1;
        _tableView.sectionFooterHeight = 1;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

@end
