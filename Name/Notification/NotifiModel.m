//
//  NotifiModel.m
//  Name
//
//  Created by hubin on 2023/3/24.
//

#import "NotifiModel.h"

@implementation NotifiModel

- (void)setName:(NSString *)name {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifiModelName"
                                                        object:@{@"msg":@"value changed",
                                                                 @"value":name}];
}

- (void)dealloc {
    NSLog(@"%@ - dealloc",self.class);
}

@end
