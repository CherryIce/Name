//
//  SkillCellDataProtocl.h
//  Name
//
//  Created by hubin on 2023/3/25.
//

#ifndef SkillCellDataProtocl_h
#define SkillCellDataProtocl_h

#import "SkillCellEventProtocl.h"
#import "SkillDataItem.h"

//SkillCellDataDelegate此协议是给Cell遵循的
@protocol SkillCellDataDelegate <NSObject>

/**
 设置Cell的数据源和事件协议 SkillCellEventDelegate这是给外部遵循的
 */
- (void) setData:(SkillDataItem *)data delegate:(id<SkillCellEventDelegate>)delegate;

@end




#endif /* SkillCellDataProtocl_h */
