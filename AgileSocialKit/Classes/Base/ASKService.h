//
//  ASKService.h
//  AgileSocialKit
//
//  Created by 周夏赛 on 2018/5/21.
//

#import <Foundation/Foundation.h>
#import "ASKUtility.h"

typedef NS_ENUM(NSUInteger, ASKRegisterType) {
    ASKRegisterTypeWechat       = 1,
    ASKRegisterTypeQQ           = 2,
    ASKRegisterTypeWeibo        = 3,
    ASKRegisterTypeAlipay       = 4,
    ASKRegisterTypeDingTalk     = 5,
};

@protocol ASKServiceProtocol <NSObject>

+ (BOOL)handleOpenURL:(NSURL *)url;

@end

@interface ASKService : NSObject

///支付宝暂时不需要key，传 nil 即可
+ (void)registerWithAppid:(NSString *)appid forType:(ASKRegisterType)type;
+ (BOOL)isRegisteredForType:(ASKRegisterType)type;
+ (NSString *)appidForType:(ASKRegisterType)type;
+ (BOOL)isInstalledForType:(ASKRegisterType)type;

+ (BOOL)handleOpenURL:(NSURL *)url;

@end
