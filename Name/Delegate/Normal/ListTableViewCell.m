//
//  ListTableViewCell.m
//  Name
//
//  Created by hubin on 2023/3/24.
//

#import "ListTableViewCell.h"

@interface ListTableViewCell ()

@end

@implementation ListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.button];
    }
    return self;
}

- (void) xxx {
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickFinishAndReturnSome:)]) {
        [self.delegate clickFinishAndReturnSome:@"点击完成了，你该干嘛干嘛"];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.button.frame = self.contentView.bounds;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UIButton *)button {
    if(!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(xxx) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}

@end
