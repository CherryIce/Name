//
//  SkillCellEventProtocl.h
//  Name
//
//  Created by hubin on 2023/3/25.
//

#ifndef SkillCellEventProtocl_h
#define SkillCellEventProtocl_h
#import "SkillDataItem.h"

@protocol SkillCellEventDelegate <NSObject>

/**
 Cell上面的事件
 */
- (void) buttonClick:(SkillDataItem *)data;

@end

#endif /* SkillCellEventProtocl_h */
