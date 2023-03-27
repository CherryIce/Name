//
//  ImageCollectionViewCell.m
//  Name
//
//  Created by hubin on 2023/3/26.
//

#import "ImageCollectionViewCell.h"

@implementation ImageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor brownColor];
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

#pragma mark - getter
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

@end
