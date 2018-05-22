//
//  ASKShareWeibo.m
//  AgileSocialKit
//
//  Created by 周夏赛 on 2018/5/21.
//

#import "ASKShareWeibo.h"

static NSString *const ASKWeiboSDKVersion = @"003233000";

@implementation ASKShareWeibo

+ (void)shareToType:(ASKShareToType)type message:(ASKShareMessage *)message completion:(ASKCompletionHandler)completion {
    if ([ASKService isRegisteredForType:ASKRegisterTypeWeibo]) {
        if ([ASKService isInstalledForType:ASKRegisterTypeWeibo]) {
            self.completion = completion;
            NSURL *url = [self shareURLWithType:type message:message];
            if (!url) return;
            [[UIApplication sharedApplication] openURL:url];
        } else {
            NSDictionary *userInfo = @{@"message" : @"Weibo uninstalled"};
            NSError *error = [NSError ask_errorWithCode:ASKErrorUninstalled userInfo:userInfo];
            !completion ?: completion(NO, nil, error);
        }
    } else {
        NSDictionary *userInfo = @{@"message" : @"please register Weibo with appId before you can use it"};
        NSError *error = [NSError ask_errorWithCode:ASKErrorUnregistered userInfo:userInfo];
        !completion ?: completion(NO, nil, error);
    }
}

+ (BOOL)handleOpenURL:(NSURL *)url {
    NSString *appid = [ASKService appidForType:ASKRegisterTypeWeibo];
    if ([url.scheme isEqualToString:[@"wb" stringByAppendingString:appid]]) {
        NSArray *items = [UIPasteboard generalPasteboard].items;
        NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithCapacity:items.count];
        for (NSDictionary *item in items) {
            for (NSString *k in item.allKeys) {
                ret[k] = [k isEqualToString:@"sdkVersion"] ? item[k] : [NSKeyedUnarchiver unarchiveObjectWithData:item[k]];
            }
        }
        if ([(NSString *)ret[@"transferObject"][@"__class"] isEqualToString:@"WBSendMessageToWeiboResponse"]) {
            NSInteger code = [ret[@"transferObject"][@"statusCode"] intValue];
            if (code == 0) {
                !self.completion ?: self.completion(YES, nil, nil);
                self.completion = nil;
            }else{
                switch (code) {
                    case -1:
                        code = ASKErrorCancelled;
                        break;
                    case -2:
                    case -8:
                        code = ASKErrorFailed;
                        break;
                        
                    default:
                        code = ASKErrorUnknown;
                        break;
                }
                [self handleErrorWithCode:code userInfo:ret[@"transferObject"]];
            }
        } else if ([(NSString *)ret[@"transferObject"][@"__class"] isEqualToString:@"WBAuthorizeResponse"]) {
            return NO;
        } else {
            NSDictionary *userInfo = @{@"message" : @"response is missing"};
            [self handleErrorWithCode:ASKErrorUnknown userInfo:userInfo];
        }
        return YES;
    } else {
        return NO;
    }
}

+ (NSURL *)shareURLWithType:(ASKShareToType)type message:(ASKShareMessage *)message {
    NSDictionary *msg;
    if (!message.image && message.text) {
        //文本分享
        msg = @{@"__class" : @"WBMessageObject",
                @"text" : message.text};
    } else if (message.image) {
        //文本+图片分享
        msg = @{@"__class" : @"WBMessageObject",
                @"text" : message.text ?: @"",
                @"imageObject" : @{@"imageData" : [ASKUtility dataWithImage:message.image]},};
    } else if (!message.text && !message.image && message.link) {
        //链接分享
        msg = @{@"__class" : @"WBMessageObject",
                @"mediaObject" : @{@"__class" : @"WBWebpageObject",
                                   @"title" : message.title ?: @"",
                                   @"description" : message.desc ?: @"",
                                   @"webpageUrl" : message.link,
                                   @"thumbnailData" : [ASKUtility dataWithImage:message.thumbnail scale:CGSizeMake(100, 100)],
                                   @"objectID" : @"identifier1"}};
    } else {
        NSDictionary *userInfo = @{@"message" : @"Weibo can only be shared to with text, image, link"};
        [self handleErrorWithCode:ASKErrorUnsupportedParams userInfo:userInfo];
        return nil;
    }
    
    NSString *uuid = [NSUUID UUID].UUIDString;
    NSArray *messageData = @[@{@"transferObject" : [NSKeyedArchiver archivedDataWithRootObject:@{@"__class" :@"WBSendMessageToWeiboRequest",
                                                                                                 @"message":msg,
                                                                                                 @"requestID" :uuid}]},
                             @{@"userInfo" : [NSKeyedArchiver archivedDataWithRootObject:@{}]},
                             @{@"app" : [NSKeyedArchiver archivedDataWithRootObject:@{@"appKey" : [ASKService appidForType:ASKRegisterTypeWeibo],
                                                                                      @"name" : [ASKUtility bundleDisplayName] ?: @"",
                                                                                      @"iconData" : [ASKUtility bundleIconData] ?: [NSData data],
                                                                                      @"bundleID" : [ASKUtility bundleIdentifier] ?: @""}]},
                             @{@"sdkVersion" : ASKWeiboSDKVersion}];
    [UIPasteboard generalPasteboard].items = messageData;
    
    NSString *link = [NSString stringWithFormat:@"weibosdk://request?id=%@&sdkversion=%@&luicode=10000360&lfid=%@", uuid, ASKWeiboSDKVersion, [ASKUtility bundleIdentifier]];
    NSURL *url = [NSURL URLWithString:link];
    return url;
}

@end
