//
//  ASKOAuth.m
//  AgileSocialKit
//
//  Created by 周夏赛 on 2018/5/21.
//

#import "ASKOAuth.h"

@implementation ASKOAuth

+ (void)authWithType:(ASKOAuthType)type authInfo:(ASKOAuthInfo *)info completion:(ASKCompletionHandler)completion {
    Class<ASKOAuthProtocol> cls = [self classWithType:type];
    if (cls) {
        [cls authWithInfo:info completion:completion];
    } else {
        NSError *error = [NSError ask_errorWithCode:ASKErrorUnsupportedType userInfo:@{@"message" : @"Unsupported oauth type"}];
        !completion ?: completion(NO, nil, error);
    }
}

+ (BOOL)handleOpenURL:(NSURL *)url {
    Class<ASKOAuthProtocol> cls = nil;
    
    cls = NSClassFromString(@"ASKOAuthWechat");
    if ([cls handleOpenURL:url]) return YES;

    return NO;
}

+ (Class<ASKOAuthProtocol>)classWithType:(ASKOAuthType)type {
    NSUInteger i = type / 100;
    NSString *clsName = nil;
    switch (i) {
        case 1:
            clsName = @"ASKOAuthWechat";
            break;
            
        default:
            return nil;
            break;
    }
    return NSClassFromString(clsName);
}


@end


@implementation ASKOAuthInfo

+ (instancetype)wechatAuthInfoWithScope:(NSString *)scope {
    ASKOAuthInfo *info = [[ASKOAuthInfo alloc] init];
    info.scope = scope;
    return info;
}

+ (instancetype)alipayAuthInfoWithAuthInfo:(NSString *)authInfo scheme:(NSString *)scheme {
    ASKOAuthInfo *info = [[ASKOAuthInfo alloc] init];
    info.authInfo = authInfo;
    info.scheme = scheme;
    return info;
}


@end
