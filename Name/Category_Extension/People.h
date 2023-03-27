//
//  People.h
//  Name
//
//  Created by hubin on 2023/3/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface People : NSObject

@property (nonatomic, copy) NSString * name;

@property (nonatomic, assign) int age;

- (instancetype)initModleWithDictionary:(NSDictionary *) dic;

@end

NS_ASSUME_NONNULL_END
