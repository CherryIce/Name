//
//  SkillTableViewCell.h
//  Name
//
//  Created by hubin on 2023/3/25.
//

#import <UIKit/UIKit.h>
#import "SkillCellDataProtocl.h"

NS_ASSUME_NONNULL_BEGIN

@interface SkillTableViewCell : UITableViewCell<SkillCellDataDelegate>

@property (nonatomic , weak) id<SkillCellEventDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
