//
//  ASKService.m
//  AgileSocialKit
//
//  Created by 周夏赛 on 2018/5/21.
//

#import "ASKService.h"

static NSMutableDictionary *appids = nil;

@implementation ASKService

+ (void)registerWithAppid:(NSString *)appid forType:(ASKRegisterType)type {
    if (!appids) {
        appids = [NSMutableDictionary dictionary];
    }
    NSString *value = appid;
    if (type == ASKRegisterTypeAlipay) {
        value = @"alipay";
    }
    appids[@(type)] = value;
}

+ (BOOL)isRegisteredForType:(ASKRegisterType)type {
    if (!appids) {
        appids = [NSMutableDictionary dictionary];
    }
    NSString *appid = appids[@(type)];
    return appid != nil && [appid isKindOfClass:[NSString class]] && appid.length > 0;
}

+ (NSString *)appidForType:(ASKRegisterType)type {
    if (!appids) {
        appids = [NSMutableDictionary dictionary];
    }
    return appids[@(type)];
}

+ (BOOL)isInstalledForType:(ASKRegisterType)type {
    NSString *scheme = nil;
    switch (type) {
        case ASKRegisterTypeWechat:
            scheme = @"weixin://";
            break;
        case ASKRegisterTypeQQ:
            scheme = @"mqqapi://";
            break;
        case ASKRegisterTypeWeibo:
            scheme = @"weibosdk://";
            break;
        case ASKRegisterTypeAlipay:
            scheme = @"alipay://";
            break;
        case ASKRegisterTypeDingTalk:
            scheme = @"dingtalk-open://";
            break;

        default:
            break;
    }
    return scheme != nil && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:scheme]];
}

+ (BOOL)handleOpenURL:(NSURL *)url {
    Class<ASKServiceProtocol> cls = nil;

    cls = NSClassFromString(@"ASKShare");
    if ([cls respondsToSelector:@selector(handleOpenURL:)] && [cls handleOpenURL:url]) return YES;

    cls = NSClassFromString(@"ASKOAuth");
    if ([cls respondsToSelector:@selector(handleOpenURL:)] && [cls handleOpenURL:url]) return YES;

    cls = NSClassFromString(@"ASKPay");
    if ([cls respondsToSelector:@selector(handleOpenURL:)] && [cls handleOpenURL:url]) return YES;
    
    return NO;
}

@end
