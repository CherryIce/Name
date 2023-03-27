//
//  RunLoopViewController.m
//  Name
//
//  Created by hubin on 2023/3/26.
//

#import "RunLoopViewController.h"
#import "ImageCollectionViewCell.h"

@interface RunLoopViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic , strong) UICollectionView * collectionView;

@property (nonatomic , strong) NSMutableArray * dataArray;

@end

@implementation RunLoopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /**
     微信开源 matrix-ios卡顿监测:https://github.com/Tencent/matrix/tree/master/matrix/matrix-iOS
     */
    
//    @autoreleasepool {
//
//    }
    [self loadData];
}

- (void) loadData {
    NSArray * bdstr = @[
        @"https://t7.baidu.com/it/u=3930750564,2979238085&fm=193&f=GIF",
        @"https://t7.baidu.com/it/u=3522949495,3570538969&fm=193&f=GIF",
        @"https://t7.baidu.com/it/u=2878377037,2986969897&fm=193&f=GIF",
        @"https://t7.baidu.com/it/u=475796824,1397609323&fm=193&f=GIF",
        @"https://t7.baidu.com/it/u=3038817810,32670274&fm=193&f=GIF",
        @"https://t7.baidu.com/it/u=434014116,2108959724&fm=193&f=GIF",
        @"https://t7.baidu.com/it/u=3599814040,3941996722&fm=193&f=GIF",
        @"https://t7.baidu.com/it/u=1228769104,2124205022&fm=193&f=GIF",
        @"https://t7.baidu.com/it/u=7250731,2558867768&fm=193&f=GIF",
        @"https://t7.baidu.com/it/u=3095438862,2748439939&fm=193&f=GIF",
        @"https://t7.baidu.com/it/u=2697203538,2641245625&fm=193&f=GIF",
        @"https://t7.baidu.com/it/u=547145230,1874976249&fm=193&f=GIF",
        @"https://t7.baidu.com/it/u=2077212613,1695106851&fm=193&f=GIF",
        @"https://t7.baidu.com/it/u=186197108,3794526213&fm=193&f=GIF",
        @"https://t7.baidu.com/it/u=3439093793,987421329&fm=193&f=GIF",
        @"https://t7.baidu.com/it/u=2503552009,125094670&fm=193&f=GIF",
        @"https://t7.baidu.com/it/u=2252345745,242858644&fm=193&f=GIF",
    ];
    
    self.dataArray = [NSMutableArray arrayWithArray:bdstr];
    
    [self.collectionView reloadData];
}

#pragma mark - delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ImageCollectionViewCell class]) forIndexPath:indexPath];
    //这里没有优化 Monitor也没有监测到特别的卡顿 不知道是不是xcode14和iphone 14pro已经优化的很好了😄
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString * urlStr = self.dataArray[indexPath.item];
        urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[[NSCharacterSet characterSetWithCharactersInString:@"#%^{}\"[]|\\<> "] invertedSet]];
        NSURL * url = [NSURL URLWithString:urlStr];
        NSData * imageData = [NSData dataWithContentsOfURL:url];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            cell.imageView.image = [UIImage imageWithData:imageData];
        });
    });
    return cell;
}

#pragma mark - getter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width - 20, 150);
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView registerClass:[ImageCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([ImageCollectionViewCell class])];
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
