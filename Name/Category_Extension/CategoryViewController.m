//
//  CategoryViewController.m
//  Name
//
//  Created by hubin on 2023/3/24.
//

#import "CategoryViewController.h"
#import "UIViewController+A.h"
#import "People+Exten.h"

@interface CategoryViewController ()

@end

@implementation CategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self doCategory];
    
    [self doExtension];
}

#pragma mark - Category
- (void) doCategory {
    self.testName = @"Category-testName";
    NSLog(@"%@",self.testName);
}

#pragma mark - Extension
- (void) doExtension {
    People * p = [[People alloc] init];
    p.name = @"name";
    p.nickName = @"extension-nickName";
    [p extensionFunc];
    NSLog(@"%@-----%@",p.name,p.nickName);
}

@end
