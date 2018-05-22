//
//  ASKShareView.h
//  ShareKit
//
//  Created by 周夏赛 on 2018/5/22.
//

#import <UIKit/UIKit.h>
#import "ASKShare.h"

@class ASKShareView;

typedef NS_ENUM(NSUInteger, ASKShareViewShareType) {
    ASKShareViewShareTypeImage       = 1,
    ASKShareViewShareTypeLink        = 2,
};

typedef NS_OPTIONS(NSUInteger, ASKShareViewTarget) {
    ASKShareViewTargetNone             = 0,
    
    ASKShareViewTargetLocalAlbum       = 1 << 0,
    ASKShareViewTargetPasteboard       = 1 << 1,
    
    ASKShareViewTargetWechatSession    = 1 << 2,
    ASKShareViewTargetWechatTimeline   = 1 << 3,
    
    ASKShareViewTargetQQFriends        = 1 << 4,
    ASKShareViewTargetQQZone           = 1 << 5,
    
    ASKShareViewTargetWeiboHome        = 1 << 6,
    
    ASKShareViewTargetDingTalkSession  = 1 << 7,
    
    ASKShareViewTargetAll              = 0xFFFFFFFF,
};


typedef void(^ASKShareViewCompletionBlock)(ASKShareViewShareType shareType, ASKShareViewTarget shareTo, ASKShareView *shareView);

extern NSString *const ASKShareViewConfigTargetTypeKey;
extern NSString *const ASKShareViewConfigTargetTitleKey;
extern NSString *const ASKShareViewConfigTargetImageKey;
extern NSString *const ASKShareViewConfigTargetPriorityKey;


@interface ASKShareView : UIView

+ (void)showShareViewAnimated:(BOOL)animated
                    withImage:(UIImage *)image
                         link:(NSString *)link
                    linkThumb:(UIImage *)thumb
                    linkTitle:(NSString *)title
              linkDescription:(NSString *)desc
                    toTargets:(ASKShareViewTarget)targets
                   completion:(ASKShareViewCompletionBlock)completion;

+ (instancetype)shareViewWithImage:(UIImage *)image
                              link:(NSString *)link
                         linkThumb:(UIImage *)thumb
                         linkTitle:(NSString *)title
                   linkDescription:(NSString *)desc
                         toTargets:(ASKShareViewTarget)targets
                        completion:(ASKShareViewCompletionBlock)completion;

- (void)showShareViewAnimated:(BOOL)animated;
- (void)closeShareViewAnimated:(BOOL)animated;

/**
 @brief 配置分享目标的参数
 @param target 第三方APP
 @param config 配置，格式如下，ASKShareViewConfigTargetPriorityKey 不填写则按照默认
 @{ASKShareViewConfigTargetTypeKey : @(ASKShareViewTargetWechatSession),
    ASKShareViewConfigTargetTitleKey : @"微信好友",
    ASKShareViewConfigTargetImageKey : bundleImageWithName(@"icon_wechat.png"),
    ASKShareViewConfigTargetPriorityKey : @(1)}
 */
- (void)setConfig:(NSDictionary *)config forType:(ASKShareViewTarget)target;
/**
 @brief 配置分享目标的参数
 @param target 第三方APP
 @param priority 优先级，默认为100。 小于100靠前，大于100靠后
 */
- (void)setPriority:(NSInteger)priority forType:(ASKShareViewTarget)target;
/**
 @brief 配置分享目标的参数
 @param target 第三方APP
 @param title 图标下面的名字
 */
- (void)setTitle:(NSString *)title forType:(ASKShareViewTarget)target;
/**
 @brief 配置分享目标的参数
 @param target 第三方APP
 @param image 图标
 */
- (void)setImage:(UIImage *)image forType:(ASKShareViewTarget)target;
/**
 @brief 配置标题
 @param text 默认"请选择分享方式"
 */
- (void)setTitleText:(NSString *)text;
/**
 @brief 配置标题颜色
 @param color 默认 0xFF333333
 */
- (void)setTitleTextColor:(UIColor *)color;
/**
 @brief 配置取消标题
 @param text 默认"取消"
 */
- (void)setCancelText:(NSString *)text;
/**
 @brief 配置取消颜色
 @param color 默认 0xFF333333
 */
- (void)setCancelTextColor:(UIColor *)color;
/**
 @brief 配置动画时长
 @param duration 默认 0.2s, 设为0 则为默认
 */
- (void)setAnimationDuration:(NSTimeInterval)duration;

@end

@interface ASKShare (DefaultShow)

/**
 @brief 本方法提供一个简单的默认展示效果及交互逻辑，如无法满足需求，请在项目中自定义交互逻辑
 */
+ (void)showShareSheetAnimated:(BOOL)animated
                     withImage:(UIImage *)image
                          link:(NSString *)link
                     linkTitle:(NSString *)title
               linkDescription:(NSString *)desc
                     linkThumb:(UIImage *)thumb
                     toTargets:(ASKShareViewTarget)targets
                    completion:(void (^)(ASKShareViewTarget target, BOOL success, NSError *error))completion;

@end
