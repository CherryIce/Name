//
//  ListTableViewCell.h
//  Name
//
//  Created by hubin on 2023/3/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ListTableViewCellDelegate <NSObject>

- (void) clickFinishAndReturnSome:(NSString *) someValue;

@end

@interface ListTableViewCell : UITableViewCell

@property (nonatomic , weak) id <ListTableViewCellDelegate> delegate;

@property (nonatomic , strong) UIButton * button;

@end

NS_ASSUME_NONNULL_END
