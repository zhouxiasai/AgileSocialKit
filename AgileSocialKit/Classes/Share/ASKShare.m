//
//  ASKShare.m
//  AgileSocialKit
//
//  Created by 周夏赛 on 2018/5/21.
//

#import "ASKShare.h"

@implementation ASKShare

+ (void)shareToType:(ASKShareToType)type message:(ASKShareMessage *)message completion:(ASKCompletionHandler)completion {
    Class<ASKShareProtocol> cls = [self classWithType:type];
    if (cls) {
        [cls shareToType:type message:message completion:completion];
    } else {
        NSError *error = [NSError ask_errorWithCode:ASKErrorUnsupportedType userInfo:@{@"message" : @"Unsupported share-to type"}];
        !completion ?: completion(NO, nil, error);
    }
}

+ (BOOL)handleOpenURL:(NSURL *)url {
    Class<ASKShareProtocol> cls = nil;
    
    cls = NSClassFromString(@"ASKShareWechat");
    if ([cls handleOpenURL:url]) return YES;
    
    cls = NSClassFromString(@"ASKShareQQ");
    if ([cls handleOpenURL:url]) return YES;
    
    cls = NSClassFromString(@"ASKShareWeibo");
    if ([cls handleOpenURL:url]) return YES;
    
    cls = NSClassFromString(@"ASKShareDingTalk");
    if ([cls handleOpenURL:url]) return YES;

    return NO;
}

+ (Class<ASKShareProtocol>)classWithType:(ASKShareToType)type {
    NSUInteger i = type / 100;
    NSString *clsName = nil;
    switch (i) {
        case 1:
            clsName = @"ASKShareWechat";
            break;
        case 2:
            clsName = @"ASKShareQQ";
            break;
        case 3:
            clsName = @"ASKShareWeibo";
            break;
        case 5:
            clsName = @"ASKShareDingTalk";
            break;

        default:
            return nil;
            break;
    }
    return NSClassFromString(clsName);
}

@end


@implementation ASKShareMessage

@end
