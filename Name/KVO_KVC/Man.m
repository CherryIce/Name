//
//  Man.m
//  Name
//
//  Created by hubin on 2023/3/24.
//

#import "Man.h"

@implementation Man

- (NSMutableArray *)comments {
    if(!_comments) {
        _comments = [NSMutableArray array];
    }
    return _comments;
}

@end
