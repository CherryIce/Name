//
//  SkillTableViewCell.m
//  Name
//
//  Created by hubin on 2023/3/25.
//

#import "SkillTableViewCell.h"

@interface SkillTableViewCell()

@property (nonatomic , strong) UIButton * button;

@property (nonatomic , strong) SkillDataItem * dataItem;

@end

@implementation SkillTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.button];
    }
    return self;
}

- (void) setData:(SkillDataItem *)data delegate:(id<SkillCellEventDelegate>)delegate {
    self.dataItem = data;
    self.delegate = delegate;
    
    [self.button setTitle:self.dataItem.value forState:UIControlStateNormal];
}

- (void) yyy {
    if (self.delegate && [self.delegate respondsToSelector:@selector(buttonClick:)]) {
        [self.delegate buttonClick:self.dataItem];
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
        [_button addTarget:self action:@selector(yyy) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}

@end
