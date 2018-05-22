//
//  ASKOAuthWechat.m
//  AgileSocialKit
//
//  Created by 周夏赛 on 2018/5/21.
//

#import "ASKOAuthWechat.h"

static NSString *const ASKOAuthWechatState = @"ASKOAuthWechatState";

@implementation ASKOAuthWechat

+ (void)authWithInfo:(ASKOAuthInfo *)info completion:(ASKCompletionHandler)completion {
    if ([ASKService isRegisteredForType:ASKRegisterTypeWechat]) {
        if ([ASKService isInstalledForType:ASKRegisterTypeWechat]) {
            self.completion = completion;
            NSString *auth = [NSString stringWithFormat:@"weixin://app/%@/auth/?scope=%@&state=%@&supportcontentfromwx=8191", [ASKService appidForType:ASKRegisterTypeWechat], info.scope, ASKOAuthWechatState];
            NSURL *url = [NSURL URLWithString:auth];
            if (!url) return;
            [[UIApplication sharedApplication] openURL:url];
        } else {
            NSDictionary *userInfo = @{@"message" : @"Wechat uninstalled"};
            NSError *error = [NSError ask_errorWithCode:ASKErrorUninstalled userInfo:userInfo];
            !completion ?: completion(NO, nil, error);
        }
    } else {
        NSDictionary *userInfo = @{@"message" : @"please register Wechat with appId before you can share to it"};
        NSError *error = [NSError ask_errorWithCode:ASKErrorUnregistered userInfo:userInfo];
        !completion ?: completion(NO, nil, error);
    }
}

+ (BOOL)handleOpenURL:(NSURL *)url {
    NSString *appid = [ASKService appidForType:ASKRegisterTypeWechat];
    if ([url.scheme isEqualToString:appid]) {
        if ([url.host isEqualToString:@"oauth"]) {
            NSDictionary *ret = [ASKUtility parseUrl:url].copy;
            !self.completion ?: self.completion(YES, ret, nil);
            self.completion = nil;
        } else {
            NSData *data = [[UIPasteboard generalPasteboard] dataForPasteboardType:@"content"];
            if (data.length) {
                NSError *serError = nil;
                NSDictionary *dic = [NSPropertyListSerialization propertyListWithData:data options:0 format:0 error:&serError];
                if (!serError) {
                    dic = dic[appid];
                    NSInteger code = [dic[@"result"] intValue];
                    NSString *state = dic[@"state"];
                    if (state && [state isEqualToString:ASKOAuthWechatState] && code != 0) {
                        switch (code) {
                            case -2:
                                code = ASKErrorCancelled;
                                break;
                            case -4:
                                code = ASKErrorFailed;
                                break;
                                
                            default:
                                code = ASKErrorUnknown;
                                break;
                        }
                        [self handleErrorWithCode:code userInfo:dic];
                    } else {
                        return NO;
                    }
                } else {
                    [self handleErrorWithCode:ASKErrorSerializeFailure userInfo:serError.userInfo];
                }
            } else {
                NSDictionary *userInfo = @{@"message" : @"response is missing"};
                [self handleErrorWithCode:ASKErrorUnknown userInfo:userInfo];
            }
        }
        return YES;
    } else {
        return NO;
    }
}

@end
