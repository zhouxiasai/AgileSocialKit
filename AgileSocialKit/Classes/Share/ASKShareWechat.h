//
//  ASKShareWechat.h
//  AgileSocialKit
//
//  Created by 周夏赛 on 2018/5/21.
//

#import "ASKItem.h"
#import "ASKShare.h"

typedef NS_ENUM(NSUInteger, ASKShareWechatLaunchMiniProgramType) {
    ASKShareWechatLaunchMiniProgramTypeRelease = 0,
    ASKShareWechatLaunchMiniProgramTypeTest = 1,
    ASKShareWechatLaunchMiniProgramTypePreview = 2
};


@interface ASKShareWechat : ASKItem <ASKShareProtocol>

///目前只支持打开小程序，暂不支持小程序回传数据（需要找前端联调）
+ (void)launchMiniProgramWithName:(NSString *)name path:(NSString *)path miniProgramType:(ASKShareWechatLaunchMiniProgramType)type completion:(ASKCompletionHandler)completion;


@end
