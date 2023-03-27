//
//  NotificationViewController.m
//  Name
//
//  Created by hubin on 2023/3/24.
//

#import "NotificationViewController.h"
#import "NotifiModel.h"

@interface NotificationViewController ()

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addObservers];
    
    NotifiModel * model = [[NotifiModel alloc] init];
    model.name = @"xxxx";
    model.name = @"yyyy";
    NSLog(@"NotifiModel - 用完了");
}

#pragma mark - Observer
- (void) addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSomeValue:) name:@"NotifiModelName" object:nil];
}

#pragma  mark - NotifiModelName
- (void) getSomeValue:(NSNotification *)value {
    //接收按传递方的格式接受即可
    NSLog(@"NotifiModelName Value = %@",value.object);
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NotifiModelName"object:nil];
}

@end
