//
//  ASKPayWechat.m
//  AgileSocialKit
//
//  Created by 周夏赛 on 2018/5/21.
//

#import "ASKPayWechat.h"

@implementation ASKPayWechat

+ (void)payWithInfo:(ASKPayInfo *)info completion:(ASKCompletionHandler)completion {
    ASKPayInfoWechat *payInfo = (ASKPayInfoWechat *)info;
    if ([ASKService isRegisteredForType:ASKRegisterTypeWechat]) {
        if ([ASKService isInstalledForType:ASKRegisterTypeWechat]) {
            self.completion = completion;
            NSString *auth = [NSString stringWithFormat:@"weixin://app/%@/pay/?%@", [ASKService appidForType:ASKRegisterTypeWechat], payInfo.toString];
            NSURL *url = [NSURL URLWithString:auth];
            if (!url) return;
            [[UIApplication sharedApplication] openURL:url];
        } else {
            NSDictionary *userInfo = @{@"message" : @"Wechat uninstalled"};
            NSError *error = [NSError ask_errorWithCode:ASKErrorUninstalled userInfo:userInfo];
            !completion ?: completion(NO, nil, error);
        }
    } else {
        NSDictionary *userInfo = @{@"message" : @"please register Wechat with appId before you can use it"};
        NSError *error = [NSError ask_errorWithCode:ASKErrorUnregistered userInfo:userInfo];
        !completion ?: completion(NO, nil, error);
    }

}

+ (BOOL)handleOpenURL:(NSURL *)url {
    NSString *appid = [ASKService appidForType:ASKRegisterTypeWechat];
    if ([url.scheme isEqualToString:appid] && [url.host isEqualToString:@"pay"]) {
        NSDictionary *ret = [ASKUtility parseUrl:url].copy;
        if (ret[@"ret"]) {
            NSInteger retCode = [ret[@"ret"] integerValue];
            NSUInteger code;
            if (retCode == 0) {
                !self.completion ?: self.completion(YES, ret, nil);
                self.completion = nil;
            } else {
                code = ASKErrorFailed;
                [self handleErrorWithCode:code userInfo:ret];
            }
        } else {
            NSDictionary *userInfo = @{@"message" : @"response is missing"};
            [self handleErrorWithCode:ASKErrorUnknown userInfo:userInfo];
        }
        return YES;
    } else {
        return NO;
    }
}

@end
