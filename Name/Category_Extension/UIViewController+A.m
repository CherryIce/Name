//
//  UIViewController+A.m
//  Name
//
//  Created by hubin on 2023/3/10.
//

#import "UIViewController+A.h"
#import <objc/runtime.h>

static inline void swizzling_exchangeMethod(Class clazz ,SEL originalSelector, SEL swizzledSelector){
    Method originalMethod = class_getInstanceMethod(clazz, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(clazz, swizzledSelector);
    
    BOOL success = class_addMethod(clazz, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (success) {
        class_replaceMethod(clazz, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@implementation UIViewController (A)

//Crash:Xcode14"Application circumvented Objective-C runtime dealloc initiation for <%s> object"
//+ (void)initialize {
////    NSLog(@"+++++++++++++++++++");
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        swizzling_exchangeMethod([UIViewController class] ,@selector(viewDidLoad), @selector(swizzling_viewDidLoad));
//    });
//}

+ (void)load{
    NSLog(@"---------------");
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzling_exchangeMethod([UIViewController class] ,@selector(viewDidLoad), @selector(swizzling_viewDidLoad));
        //@selector(dealloc) ARC forbids use of ‘dealloc’ in a @selector
        swizzling_exchangeMethod([UIViewController class] ,NSSelectorFromString(@"dealloc"), @selector(swizzling_dealloc));
    });
}

- (void)swizzling_viewDidLoad {
    [self swizzling_viewDidLoad];
    [self funcA];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void) swizzling_dealloc {
    NSLog(@"%@ dealloc",self.class);
    [self swizzling_dealloc];
}

- (void)funcA {
    NSLog(@"%@ do funcA",self.class);
    
}

- (void)setTestName:(NSString *)testName {
    objc_setAssociatedObject(self, @selector(testName), testName, OBJC_ASSOCIATION_COPY);
}

- (NSString *)testName {
    return objc_getAssociatedObject(self, @selector(testName));
}

@end
