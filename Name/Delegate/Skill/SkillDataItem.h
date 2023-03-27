//
//  SkillDataItem.h
//  Name
//
//  Created by hubin on 2023/3/25.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SkillDataItem : NSObject

/**
 当前数据模型对应Cell
 */
@property (nonatomic , strong) Class cellClass;

/**
 其他属性
 */
@property (nonatomic , copy) NSString * title;

@property (nonatomic , copy) NSString * value;

/**
 其他属性...
 */

@end

NS_ASSUME_NONNULL_END
