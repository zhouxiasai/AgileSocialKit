//
//  ASKShareView.m
//  ShareKit
//
//  Created by 周夏赛 on 2018/5/22.
//

#import "ASKShareView.h"

NSString *const ASKShareViewConfigTargetTypeKey = @"shareToType";
NSString *const ASKShareViewConfigTargetTitleKey = @"shareToTitle";
NSString *const ASKShareViewConfigTargetImageKey = @"shareToImage";
NSString *const ASKShareViewConfigTargetPriorityKey = @"shareToPriority";


static NSString *       const ASKShareViewTitleText = @"选择分享方式";
static CGFloat          const ASKShareViewTitleTextSize = 14;
static NSInteger        const ASKShareViewTitleTextColor = 0xFF333333;
static NSString *       const ASKShareViewCancelText = @"取消";
static CGFloat          const ASKShareViewCancelTextSize = 16;
static NSInteger        const ASKShareViewCancelTextColor = 0xFF333333;
static NSInteger        const ASKShareViewLineColor = 0xFFF2F2F2;
static NSTimeInterval   const ASKShareViewAnimationTimeInterval = 0.2;

static BOOL ASKShareViewIsShown = NO;

@interface ASKShareViewShareTypeCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *linkView;
@property (nonatomic, strong) UIImageView *thumbIV;
@property (nonatomic, strong) UILabel *titleLb;
@property (nonatomic, strong) UIButton *selectBtn;

- (void)configWithType:(ASKShareViewShareType)type image:(UIImage *)image thumb:(UIImage *)thumb title:(NSString *)title;

@end

@interface ASKShareViewShareToCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *textLabel;

- (void)configWithImage:(UIImage *)image text:(NSString *)text;

@end

@interface ASKShareView () <UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UICollectionView *shareTypeCollectionView;
@property (nonatomic, strong) UICollectionView *shareToCollectionView;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *shareTypeArray;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *shareToArray;

@property (nonatomic, copy) ASKShareViewCompletionBlock completion;
@property (nonatomic, assign) ASKShareViewShareType shareType;
@property (nonatomic, assign) ASKShareViewTarget shareTo;

//可选配置
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSDictionary *> *targetConfigs;

@end

@implementation ASKShareView {
    BOOL _animated;
    NSTimeInterval _duration;
    UIImage *_image;
    NSString *_link;
    UIImage *_thumb;
    NSString *_title;
    NSString *_desc;
    NSUInteger _targets;
}

- (instancetype)initWithImage:(UIImage *)image link:(NSString *)link thumb:(UIImage *)thumb title:(NSString *)title desc:(NSString *)desc toTargets:(ASKShareViewTarget)targets completion:(ASKShareViewCompletionBlock)completion {
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        _image = image;
        _link = link;
        _thumb = thumb;
        _title = title;
        _desc = desc;
        _targets = targets;
        _completion = completion;
        [self configureSubviews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configureSubviews];
    }
    return self;
}

- (void)configureSubviews {
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.shareTypeCollectionView];
    [self.contentView addSubview:self.shareToCollectionView];
    [self.contentView addSubview:self.line];
    [self.contentView addSubview:self.cancelButton];
    [self configureLayouts];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
}

- (void)configureLayouts {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat adaptRatio = screenWidth / 375;
    CGFloat contentHeight, shareTypeHeight, shareToHeight;
    if (_image && _link) {
        contentHeight = 380 * adaptRatio;
        shareTypeHeight = ((UICollectionViewFlowLayout *)self.shareTypeCollectionView.collectionViewLayout).itemSize.height;
    } else {
        contentHeight = 200 * adaptRatio;
        shareTypeHeight = 0;
    }
    shareToHeight = ((UICollectionViewFlowLayout *)self.shareToCollectionView.collectionViewLayout).itemSize.height;
    self.contentView.frame = CGRectMake(0, screenHeight, screenWidth, contentHeight);
    self.titleLabel.frame = CGRectMake(20 * adaptRatio, 0, screenWidth - 20 * adaptRatio, 50 * adaptRatio);
    self.shareTypeCollectionView.frame = CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame), screenWidth, shareTypeHeight);
    self.shareToCollectionView.frame = CGRectMake(0, CGRectGetMaxY(self.shareTypeCollectionView.frame), screenWidth, shareToHeight);
    self.line.frame = CGRectMake(0, CGRectGetMaxY(self.shareToCollectionView.frame), screenWidth, 1);
    self.cancelButton.frame = CGRectMake(0, CGRectGetMaxY(self.line.frame), screenWidth, 50 * adaptRatio);
}


#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.shareTypeCollectionView) {
        [self.shareTypeArray removeAllObjects];
        if (_image) {
            [self.shareTypeArray addObject:@(ASKShareViewShareTypeImage)];
        }
        if (_link) {
            [self.shareTypeArray addObject:@(ASKShareViewShareTypeLink)];
        }
        return self.shareTypeArray.count;
    } else if (collectionView == self.shareToCollectionView) {
        [self.shareToArray removeAllObjects];

        if (_targets & ASKShareViewTargetWechatSession) {
            [self.shareToArray addObject:self.targetConfigs[@(ASKShareViewTargetWechatSession)]];
        }
        if (_targets & ASKShareViewTargetWechatTimeline) {
            [self.shareToArray addObject:self.targetConfigs[@(ASKShareViewTargetWechatTimeline)]];
        }
        
        if ((!self.shareType && _image) || self.shareType == ASKShareViewShareTypeImage) {
            if (_targets & ASKShareViewTargetLocalAlbum) {
                [self.shareToArray addObject:self.targetConfigs[@(ASKShareViewTargetLocalAlbum)]];
            }
        } else if ((!self.shareType && _link) || self.shareType == ASKShareViewShareTypeLink) {
            if (_targets & ASKShareViewTargetPasteboard) {
                [self.shareToArray addObject:self.targetConfigs[@(ASKShareViewTargetPasteboard)]];
            }
        }
        
        if (_targets & ASKShareViewTargetQQFriends) {
            [self.shareToArray addObject:self.targetConfigs[@(ASKShareViewTargetQQFriends)]];
        }
        if (_targets & ASKShareViewTargetQQZone) {
            [self.shareToArray addObject:self.targetConfigs[@(ASKShareViewTargetQQZone)]];
        }
        
        if (_targets & ASKShareViewTargetWeiboHome) {
            [self.shareToArray addObject:self.targetConfigs[@(ASKShareViewTargetWeiboHome)]];
        }
        
        if (_targets & ASKShareViewTargetDingTalkSession) {
            [self.shareToArray addObject:self.targetConfigs[@(ASKShareViewTargetDingTalkSession)]];
        }
        [self.shareToArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSInteger priority1 = [[obj1 objectForKey:ASKShareViewConfigTargetPriorityKey] integerValue];
            NSInteger priority2 = [[obj2 objectForKey:ASKShareViewConfigTargetPriorityKey] integerValue];
            return priority1 > priority2 ? NSOrderedDescending : priority1 < priority2 ? NSOrderedAscending : NSOrderedSame;
        }];
        return self.shareToArray.count;
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.shareTypeCollectionView) {
        ASKShareViewShareTypeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ASKShareViewShareTypeCell class]) forIndexPath:indexPath];
        [cell configWithType:[self.shareTypeArray[indexPath.row] integerValue] image:_image thumb:_thumb title:_title];
        return cell;
    } else if (collectionView == self.shareToCollectionView) {
        ASKShareViewShareToCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ASKShareViewShareToCell class]) forIndexPath:indexPath];
        [cell configWithImage:self.shareToArray[indexPath.row][ASKShareViewConfigTargetImageKey] text:self.shareToArray[indexPath.row][ASKShareViewConfigTargetTitleKey]];
        return cell;
    } else {
        return nil;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.shareTypeCollectionView) {
        self.shareType = self.shareTypeArray[indexPath.row].integerValue;
        for (int i = 0; i < self.shareTypeArray.count; i++) {
            if (i != indexPath.row) {
                NSIndexPath *otherIndexPath = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
                [collectionView deselectItemAtIndexPath:otherIndexPath animated:YES];
            }
        }
        [self.shareToCollectionView reloadData];
    } else if (collectionView == self.shareToCollectionView) {
        self.shareTo = [self.shareToArray[indexPath.row][ASKShareViewConfigTargetTypeKey] integerValue];
        [collectionView deselectItemAtIndexPath:indexPath animated:true];
        !self.completion ?: self.completion(self.shareType, self.shareTo, self);
    }
}

#pragma mark - actions

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint location = [touch locationInView:self];
    if (CGRectContainsPoint(self.contentView.frame, location)) {
        return NO;
    } else {
        return YES;
    }
}

- (void)tapGestureAction:(UITapGestureRecognizer *)tapGesture {
    CGPoint location = [tapGesture locationInView:self];
    if (!CGRectContainsPoint(self.contentView.frame, location)) {
        [self closeShareViewAnimated:_animated];
    }
}

- (void)buttonAction:(UIButton *)sender {
    if (sender == self.cancelButton) {
        [self closeShareViewAnimated:_animated];
    }
}

#pragma mark - getters & setters

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.hidden = YES;
    }
    return _contentView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = ASKShareViewTitleText;
        _titleLabel.font = ASKSemiboldPingFangFontWithSize(ASKShareViewTitleTextSize);
        _titleLabel.textColor = ASKColorWithARGB(ASKShareViewTitleTextColor);
    }
    return _titleLabel;
}

- (UIView *)line {
    if (!_line) {
        _line = ASKDrawLine(ASKColorWithARGB(ASKShareViewLineColor));
    }
    return _line;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:ASKShareViewCancelText forState:UIControlStateNormal];
        [_cancelButton setTitleColor:ASKColorWithARGB(ASKShareViewCancelTextColor) forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = ASKRegularPingFangFontWithSize(ASKShareViewCancelTextSize);
        [_cancelButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UICollectionView *)shareTypeCollectionView {
    if (!_shareTypeCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        //左右边距 20,   图片间距 16
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat adaptRatio = screenWidth / 375;
        CGFloat hMargin = 20 * adaptRatio;
        CGFloat itemSpace = 16 * adaptRatio;
        
        layout.minimumLineSpacing = itemSpace;
        CGFloat hInset = hMargin - itemSpace / 2;
        layout.sectionInset = UIEdgeInsetsMake(0, hInset, 0, hInset);
        //每页2项
        CGFloat itemsPerPage = 2;
        CGFloat itemWidth = (screenWidth - hMargin * 2 - itemSpace) / itemsPerPage;
        CGFloat itemHeight = itemWidth * 182 / 160;
        layout.itemSize = CGSizeMake(itemWidth, itemHeight);
        
        _shareTypeCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _shareTypeCollectionView.backgroundColor = [UIColor clearColor];
        _shareTypeCollectionView.delegate = self;
        _shareTypeCollectionView.dataSource = self;
        _shareTypeCollectionView.bounces = NO;
        _shareTypeCollectionView.showsHorizontalScrollIndicator = NO;
        [_shareTypeCollectionView registerClass:[ASKShareViewShareTypeCell class] forCellWithReuseIdentifier:NSStringFromClass([ASKShareViewShareTypeCell class])];
    }
    return _shareTypeCollectionView;
}

- (UICollectionView *)shareToCollectionView {
    if (!_shareToCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat adaptRatio = screenWidth / 375;
        
        CGFloat itemWidth = 75 * adaptRatio;
        CGFloat itemHeight = 95 * adaptRatio;
        layout.itemSize = CGSizeMake(itemWidth, itemHeight);
        
        _shareToCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _shareToCollectionView.backgroundColor = [UIColor clearColor];
        _shareToCollectionView.delegate = self;
        _shareToCollectionView.dataSource = self;
        _shareToCollectionView.showsHorizontalScrollIndicator = NO;
        [_shareToCollectionView registerClass:[ASKShareViewShareToCell class] forCellWithReuseIdentifier:NSStringFromClass([ASKShareViewShareToCell class])];
    }
    return _shareToCollectionView;
}

- (NSMutableArray<NSNumber *> *)shareTypeArray {
    if (!_shareTypeArray) {
        _shareTypeArray = [NSMutableArray array];
    }
    return _shareTypeArray;
}

- (NSMutableArray<NSDictionary *> *)shareToArray {
    if (!_shareToArray) {
        _shareToArray = [NSMutableArray array];
    }
    return _shareToArray;
}

- (NSMutableDictionary<NSNumber *,NSDictionary *> *)targetConfigs {
    if (!_targetConfigs) {
        NSDictionary *dict = @{
                               @(ASKShareViewTargetWechatSession) :     @{ASKShareViewConfigTargetTypeKey : @(ASKShareViewTargetWechatSession),
                                                                          ASKShareViewConfigTargetTitleKey : @"微信好友",
                                                                          ASKShareViewConfigTargetImageKey : bundleImageWithName(@"icon_wechat.png"),
                                                                          ASKShareViewConfigTargetPriorityKey : @(100)},
                               @(ASKShareViewTargetWechatTimeline) :    @{ASKShareViewConfigTargetTypeKey : @(ASKShareViewTargetWechatTimeline),
                                                                          ASKShareViewConfigTargetTitleKey : @"微信朋友圈",
                                                                          ASKShareViewConfigTargetImageKey : bundleImageWithName(@"icon_moments.png"),
                                                                          ASKShareViewConfigTargetPriorityKey : @(100)},
                               @(ASKShareViewTargetLocalAlbum) :        @{ASKShareViewConfigTargetTypeKey : @(ASKShareViewTargetLocalAlbum),
                                                                          ASKShareViewConfigTargetTitleKey : @"保存到相册",
                                                                          ASKShareViewConfigTargetImageKey : bundleImageWithName(@"icon_save.png"),
                                                                          ASKShareViewConfigTargetPriorityKey : @(100)},
                               @(ASKShareViewTargetPasteboard) :        @{ASKShareViewConfigTargetTypeKey : @(ASKShareViewTargetPasteboard),
                                                                          ASKShareViewConfigTargetTitleKey : @"复制链接",
                                                                          ASKShareViewConfigTargetImageKey : bundleImageWithName(@"icon_link.png"),
                                                                          ASKShareViewConfigTargetPriorityKey : @(100)},
                               @(ASKShareViewTargetQQFriends) :         @{ASKShareViewConfigTargetTypeKey : @(ASKShareViewTargetQQFriends),
                                                                          ASKShareViewConfigTargetTitleKey : @"QQ好友",
                                                                          ASKShareViewConfigTargetImageKey : bundleImageWithName(@"icon_qq.png"),
                                                                          ASKShareViewConfigTargetPriorityKey : @(100)},
                               @(ASKShareViewTargetQQZone) :            @{ASKShareViewConfigTargetTypeKey : @(ASKShareViewTargetQQZone),
                                                                          ASKShareViewConfigTargetTitleKey : @"QQ空间",
                                                                          ASKShareViewConfigTargetImageKey : bundleImageWithName(@"icon_qqzone.png"),
                                                                          ASKShareViewConfigTargetPriorityKey : @(100)},
                               @(ASKShareViewTargetWeiboHome) :         @{ASKShareViewConfigTargetTypeKey : @(ASKShareViewTargetWeiboHome),
                                                                          ASKShareViewConfigTargetTitleKey : @"新浪微博",
                                                                          ASKShareViewConfigTargetImageKey : bundleImageWithName(@"icon_weibo.png"),
                                                                          ASKShareViewConfigTargetPriorityKey : @(100)},
                               @(ASKShareViewTargetDingTalkSession) :   @{ASKShareViewConfigTargetTypeKey : @(ASKShareViewTargetDingTalkSession),
                                                                          ASKShareViewConfigTargetTitleKey : @"钉钉",
                                                                          ASKShareViewConfigTargetImageKey : bundleImageWithName(@"icon_dingtalk.png"),
                                                                          ASKShareViewConfigTargetPriorityKey : @(100)}
                               };
        _targetConfigs = [NSMutableDictionary dictionaryWithDictionary:dict];
    }
    return _targetConfigs;
}

- (void)setConfig:(NSDictionary *)config forType:(ASKShareViewTarget)target {
    NSAssert(config[ASKShareViewConfigTargetTypeKey] != nil, @"value for ASKShareViewConfigTargetTypeKey is needed");
    NSAssert(config[ASKShareViewConfigTargetTitleKey] != nil, @"value for ASKShareViewConfigTargetTitleKey is needed");
    NSAssert(config[ASKShareViewConfigTargetImageKey] != nil, @"value for ASKShareViewConfigTargetImageKey is needed");
   [_targetConfigs setObject:config forKey:@(target)];
}

- (void)setPriority:(NSInteger)priority forType:(ASKShareViewTarget)target {
    NSMutableDictionary *config = self.targetConfigs[@(target)].mutableCopy;
    [config setObject:@(priority) forKey:ASKShareViewConfigTargetPriorityKey];
    [self.targetConfigs setObject:config forKey:@(target)];
}

- (void)setTitle:(NSString *)title forType:(ASKShareViewTarget)target {
    NSAssert(title != nil, @"name cannot be nil");
    NSMutableDictionary *config = self.targetConfigs[@(target)].mutableCopy;
    [config setObject:title forKey:ASKShareViewConfigTargetTitleKey];
    [self.targetConfigs setObject:config forKey:@(target)];
}

- (void)setImage:(UIImage *)image forType:(ASKShareViewTarget)target {
    NSAssert(image != nil, @"image cannot be nil");
    NSMutableDictionary *config = self.targetConfigs[@(target)].mutableCopy;
    [config setObject:image forKey:ASKShareViewConfigTargetImageKey];
    [self.targetConfigs setObject:config forKey:@(target)];
}

- (void)setTitleText:(NSString *)text {
    self.titleLabel.text = text;
}

- (void)setTitleTextColor:(UIColor *)color {
    self.titleLabel.textColor = color;
}

- (void)setCancelText:(NSString *)text {
    [self.cancelButton setTitle:text forState:UIControlStateNormal];
}

- (void)setCancelTextColor:(UIColor *)color {
    [self.cancelButton setTitleColor:color forState:UIControlStateNormal];
}

- (void)setAnimationDuration:(NSTimeInterval)duration {
    _duration = duration;
}

#pragma mark - helper

UIImage *bundleImageWithName(NSString *name) {
    NSBundle *bundle = [NSBundle bundleForClass:[ASKShareView class]];
    NSURL *bundleURL = [bundle URLForResource:@"Share" withExtension:@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithURL: bundleURL];
    UIImage *image = [UIImage imageNamed:name inBundle:resourceBundle compatibleWithTraitCollection:nil];
    return image;
}

UIFont *ASKSemiboldPingFangFontWithSize(CGFloat size) {
    return [UIFont fontWithName:@"PingFangSC-Semibold" size:size] ?: [UIFont boldSystemFontOfSize:size];
}

UIFont *ASKRegularPingFangFontWithSize(CGFloat size) {
    return [UIFont fontWithName:@"PingFangSC-Regular" size:size] ?: [UIFont systemFontOfSize:size];
}

UIColor *ASKColorWithARGB(NSInteger argb) {
    return [UIColor colorWithRed:((float) ((argb & 0xFF0000)   >> 16)) / 0xFF
                           green:((float) ((argb & 0xFF00)     >> 8))  / 0xFF
                            blue:((float)  (argb & 0xFF))              / 0xFF
                           alpha:((float) ((argb & 0xFF000000) >> 24)) / 0xFF];
}

UIView *ASKDrawLine(UIColor *color) {
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = color;
    return line;
}

#pragma mark - methods
+ (void)showShareViewAnimated:(BOOL)animated withImage:(UIImage *)image link:(NSString *)link linkThumb:(UIImage *)thumb linkTitle:(NSString *)title linkDescription:(NSString *)desc toTargets:(ASKShareViewTarget)targets completion:(ASKShareViewCompletionBlock)completion {
    ASKShareView *shareView = [ASKShareView shareViewWithImage:image link:link linkThumb:thumb linkTitle:title linkDescription:desc toTargets:targets completion:completion];
   [shareView showShareViewAnimated:animated];
}

+ (instancetype)shareViewWithImage:(UIImage *)image link:(NSString *)link linkThumb:(UIImage *)thumb linkTitle:(NSString *)title linkDescription:(NSString *)desc toTargets:(ASKShareViewTarget)targets completion:(ASKShareViewCompletionBlock)completion {
    ASKShareView *shareView = [[ASKShareView alloc] initWithImage:image link:link thumb:thumb title:title desc:desc toTargets:targets completion:completion];
    return shareView;
}

- (void)showShareViewAnimated:(BOOL)animated {
    if (ASKShareViewIsShown) {
        return;
    }
    ASKShareViewIsShown = YES;
    _animated = animated;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    CGRect frame = self.contentView.frame;
    if (@available(iOS 11.0, *)) {
        frame.size.height += self.safeAreaInsets.bottom;
        self.contentView.frame = frame;
    }
    
    self.contentView.hidden = NO;
    CGFloat yDistance = frame.size.height;
    if (animated) {
        [UIView animateWithDuration:_duration == 0 ? ASKShareViewAnimationTimeInterval : _duration animations:^{
            self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
            self.contentView.transform = CGAffineTransformMakeTranslation(0, -yDistance);
        }];
    } else {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        self.contentView.transform = CGAffineTransformMakeTranslation(0, -yDistance);
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1/60.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        if ([self.shareTypeCollectionView cellForItemAtIndexPath:indexPath]) {
            [self.shareTypeCollectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            self.shareType = self.shareTypeArray[indexPath.row].integerValue;
        }
    });
}

- (void)closeShareViewAnimated:(BOOL)animated {
    ASKShareViewIsShown = NO;
    if (animated) {
        [UIView animateWithDuration:_duration == 0 ? ASKShareViewAnimationTimeInterval : _duration animations:^{
            self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
            self.contentView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    } else{
        self.contentView.transform = CGAffineTransformIdentity;
        [self removeFromSuperview];
    }
}

@end

#pragma mark - ASKShareViewShareTypeCell -
@implementation ASKShareViewShareTypeCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configureSubviews];
    }
    return self;
}

- (void)configureSubviews {
    self.layer.cornerRadius = 4;
    self.layer.borderWidth = 1;
    self.layer.borderColor = ASKColorWithARGB(0xFFF2F2F2).CGColor;
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.linkView];
    [self.linkView addSubview:self.thumbIV];
    [self.linkView addSubview:self.titleLb];
    [self.contentView addSubview:self.selectBtn];
    UIView *selectedView = [[UIView alloc] initWithFrame:self.bounds];
    selectedView.backgroundColor = ASKColorWithARGB(0xFFF2F2F2);
    self.selectedBackgroundView = selectedView;
}

#pragma mark - getters & setters
- (UIImageView *)imageView {
    if (!_imageView) {
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat adaptRatio = screenWidth / 375;
        CGFloat x = 20 * adaptRatio;
        CGFloat y = x;
        CGFloat width = CGRectGetWidth(self.frame) - 2 * x;
        CGFloat height = CGRectGetHeight(self.frame) - 60 * adaptRatio - x;
        CGRect frame = CGRectMake(x, y, width, height);
        _imageView = [[UIImageView alloc] initWithFrame:frame];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoom:)]];
    }
    return _imageView;
}

- (UIView *)linkView {
    if (!_linkView) {
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat adaptRatio = screenWidth / 375;
        CGFloat x = 20 * adaptRatio;
        CGFloat y = 60 * adaptRatio;
        CGFloat width = CGRectGetWidth(self.frame) - 2 * x;
        CGFloat height = 40 * adaptRatio;
        CGRect frame = CGRectMake(x, y, width, height);
        _linkView = [[UIView alloc] initWithFrame:frame];
    }
    return _linkView;
}

- (UIImageView *)thumbIV {
    if (!_thumbIV) {
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat adaptRatio = screenWidth / 375;
        CGFloat width = 40 * adaptRatio;
        CGFloat height = width;
        CGRect frame = CGRectMake(0, 0, width, height);
        _thumbIV = [[UIImageView alloc] initWithFrame:frame];
        _thumbIV.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _thumbIV;
}

- (UILabel *)titleLb {
    if (!_titleLb) {
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat adaptRatio = screenWidth / 375;
        CGFloat x = CGRectGetWidth(self.thumbIV.frame) + 7 * adaptRatio;
        CGFloat width = CGRectGetWidth(self.linkView.frame) - x;
        CGFloat height = CGRectGetHeight(self.linkView.frame);
        CGRect frame = CGRectMake(x, 0, width, height);
        _titleLb = [[UILabel alloc] initWithFrame:frame];
        _titleLb.font = ASKRegularPingFangFontWithSize(12);
        _titleLb.textColor = ASKColorWithARGB(0xFF666666);
        _titleLb.numberOfLines = 0;
    }
    return _titleLb;
}

- (UIButton *)selectBtn {
    if (!_selectBtn) {
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat adaptRatio = screenWidth / 375;
        CGFloat x = 0;
        CGFloat y = CGRectGetHeight(self.frame) - 40 * adaptRatio;
        CGFloat width = CGRectGetWidth(self.frame);
        CGFloat height = 20 * adaptRatio;
        CGRect frame = CGRectMake(x, y, width, height);
        _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectBtn.userInteractionEnabled = false;
        _selectBtn.frame = frame;
        _selectBtn.titleLabel.font = ASKRegularPingFangFontWithSize(14);
        _selectBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
        [_selectBtn setTitleColor:ASKColorWithARGB(0xFF333333) forState:UIControlStateNormal];
        [_selectBtn setImage:bundleImageWithName(@"icon_unselected") forState:UIControlStateNormal];
        [_selectBtn setImage:bundleImageWithName(@"icon_selected_red") forState:UIControlStateSelected];
    }
    return _selectBtn;
}

#pragma mark - methods
- (void)configWithType:(ASKShareViewShareType)type image:(UIImage *)image thumb:(UIImage *)thumb title:(NSString *)title {
    self.imageView.hidden = !(type == ASKShareViewShareTypeImage);
    self.linkView.hidden = (type == ASKShareViewShareTypeImage);
    self.imageView.image = image;
    self.thumbIV.image = thumb;
    self.titleLb.text = title;
    [self.selectBtn setTitle:(type == ASKShareViewShareTypeImage) ? @"图片形式" : @"链接形式" forState:UIControlStateNormal];
}

- (void)zoom:(UITapGestureRecognizer *)tap {
    UIView *view = tap.view;
    if (view == self.imageView) {
        //放大
        UIView *background = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        background.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
        background.alpha = 0;
        [background addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoom:)]];
        //TODO:背景色可配置
        CGRect frame = [self.imageView convertRect:self.imageView.bounds toView:[UIApplication sharedApplication].keyWindow];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = self.imageView.image;
        imageView.tag = 100;
        [background addSubview:imageView];
        
        [[UIApplication sharedApplication].keyWindow addSubview:background];
        [UIView animateWithDuration:ASKShareViewAnimationTimeInterval animations:^{
            imageView.frame = background.bounds;
            background.alpha = 1;
        }];
    } else {
        //缩小
        UIView *background = tap.view;
        UIImageView *imageView = [background viewWithTag:100];
        [UIView animateWithDuration:ASKShareViewAnimationTimeInterval animations:^{
            CGRect frame = [self.imageView convertRect:self.imageView.bounds toView:[UIApplication sharedApplication].keyWindow];
            imageView.frame = frame;
            background.alpha = 0;
        } completion:^(BOOL finished) {
            [background removeFromSuperview];
        }];
    }
}

- (void)zoomOut:(UITapGestureRecognizer *)tap {
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.selectBtn.selected = selected;
    self.imageView.userInteractionEnabled = selected;
}

@end

#pragma mark - ASKShareViewShareToCell -
@implementation ASKShareViewShareToCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configureSubviews];
    }
    return self;
}

- (void)configureSubviews {
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.textLabel];
}

#pragma mark - getters & setters
- (UIImageView *)imageView {
    if (!_imageView) {
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat adaptRatio = screenWidth / 375;
        CGFloat width = 30;
        CGFloat height = width;
        CGFloat x = CGRectGetWidth(self.frame) / 2 - width / 2;
        CGFloat y = 20 * adaptRatio;
        CGRect frame = CGRectMake(x, y, width, height);
        _imageView = [[UIImageView alloc] initWithFrame:frame];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat adaptRatio = screenWidth / 375;
        CGFloat x = 0;
        CGFloat y = CGRectGetMaxY(self.imageView.frame) + 10 * adaptRatio;
        CGFloat width = CGRectGetWidth(self.frame);
        CGFloat height = 20 * adaptRatio;
        CGRect frame = CGRectMake(x, y, width, height);
        _textLabel = [[UILabel alloc] initWithFrame:frame];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.textColor = ASKColorWithARGB(0xFF333333);
        _textLabel.font = ASKRegularPingFangFontWithSize(12);
    }
    return _textLabel;
}

#pragma mark - methods
- (void)configWithImage:(UIImage *)image text:(NSString *)text {
    self.imageView.image = image;
    self.textLabel.text = text;
}

@end

#pragma mark - ASKShare + DefaultShow -
@implementation ASKShare (DefaultShow)

+ (void)showShareSheetAnimated:(BOOL)animated withImage:(UIImage *)image link:(NSString *)link linkTitle:(NSString *)title linkDescription:(NSString *)desc linkThumb:(UIImage *)thumb toTargets:(ASKShareViewTarget)targets completion:(void (^)(ASKShareViewTarget, BOOL, NSError *))completion {
    [ASKShareView showShareViewAnimated:animated withImage:image link:link linkThumb:thumb linkTitle:title linkDescription:desc toTargets:[self validateTargets:targets] completion:^(ASKShareViewShareType shareType, ASKShareViewTarget shareTo, ASKShareView *shareView) {
        [self shareMessageTo:shareTo type:shareType withImage:image link:link linkTitle:title linkDescription:desc linkThumb:thumb completion:completion];
        [shareView closeShareViewAnimated:animated];
    }];
}


+ (void)shareMessageTo:(ASKShareViewTarget)target type:(ASKShareViewShareType)shareType withImage:(UIImage *)image link:(NSString *)link linkTitle:(NSString *)title linkDescription:(NSString *)desc linkThumb:(UIImage *)thumb completion:(void (^)(ASKShareViewTarget, BOOL, NSError *))completion {
    ASKShareMessage *message = [[ASKShareMessage alloc] init];
    message.link = link;
    message.title = title;
    message.desc = desc;
    message.thumbnail = thumb;
    if (shareType == ASKShareViewShareTypeImage) {
        message.image = image;
    }
    ASKShareToType shareTo = ASKShareToTypeWithTarget(target);
    if (shareTo == ASKShareToLocalAlbum) {
        [ASKUtility saveImageToAlbum:image completion:^(BOOL success, NSError *error) {
            !completion ?: completion(target, success, error);
        }];
    } else if (shareTo == ASKShareToPasteboard) {
        NSString *content = title ?: @"";
        content = [content stringByAppendingString:link];
        [ASKUtility copyContentToPasteboard:content];
        !completion ?: completion(target, YES, nil);
    } else {
        [self shareToType:shareTo message:message completion:^(BOOL success, NSDictionary *data, NSError *error) {
            !completion ?: completion(target, success, error);
        }];
    }
}


ASKShareToType ASKShareToTypeWithTarget(ASKShareViewTarget target) {
    switch (target) {
        case ASKShareViewTargetLocalAlbum:
            return ASKShareToLocalAlbum;
            break;
        case ASKShareViewTargetPasteboard:
            return ASKShareToPasteboard;
            break;
        case ASKShareViewTargetWechatSession:
            return ASKShareToWechatSession;
            break;
        case ASKShareViewTargetWechatTimeline:
            return ASKShareToWechatTimeline;
            break;
        case ASKShareViewTargetQQFriends:
            return ASKShareToQQFriends;
            break;
        case ASKShareViewTargetQQZone:
            return ASKShareToQQZone;
            break;
        case ASKShareViewTargetWeiboHome:
            return ASKShareToWeiboHome;
            break;
        case ASKShareViewTargetDingTalkSession:
            return ASKShareToDingTalkSession;
            break;
        default:
            return 0;
            break;
    }
}

+ (ASKShareViewTarget)validateTargets:(ASKShareViewTarget)targets {
    ASKShareViewTarget result = ASKShareViewTargetNone;
    
    if (targets & ASKShareViewTargetLocalAlbum) {
        result = result | ASKShareViewTargetLocalAlbum;
    }
    if (targets & ASKShareViewTargetPasteboard) {
        result = result | ASKShareViewTargetPasteboard;
    }
    if ([ASKService isRegisteredForType:ASKRegisterTypeWechat]) {
        if (targets & ASKShareViewTargetWechatSession) {
            result = result | ASKShareViewTargetWechatSession;
        }
        if (targets & ASKShareViewTargetWechatTimeline) {
            result = result | ASKShareViewTargetWechatTimeline;
        }
    }
    if ([ASKService isRegisteredForType:ASKRegisterTypeQQ]) {
        if (targets & ASKShareViewTargetQQFriends) {
            result = result | ASKShareViewTargetQQFriends;
        }
        if (targets & ASKShareViewTargetQQZone) {
            result = result | ASKShareViewTargetQQZone;
        }
    }
    if ([ASKService isRegisteredForType:ASKRegisterTypeWeibo]) {
        if (targets & ASKShareViewTargetWeiboHome) {
            result = result | ASKShareViewTargetWeiboHome;
        }
    }
    if ([ASKService isRegisteredForType:ASKRegisterTypeDingTalk]) {
        if (targets & ASKShareViewTargetDingTalkSession) {
            result = result | ASKShareViewTargetDingTalkSession;
        }
    }
    return result;
}


@end
