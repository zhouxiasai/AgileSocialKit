//
//  ASKShareWechat.m
//  AgileSocialKit
//
//  Created by 周夏赛 on 2018/5/21.
//

#import "ASKShareWechat.h"

@implementation ASKShareWechat

+ (void)shareToType:(ASKShareToType)type message:(ASKShareMessage *)message completion:(ASKCompletionHandler)completion {
    if ([ASKService isRegisteredForType:ASKRegisterTypeWechat]) {
        if ([ASKService isInstalledForType:ASKRegisterTypeWechat]) {
            self.completion = completion;
            NSURL *url = [self shareURLWithType:type message:message];
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
    if ([url.scheme isEqualToString:appid]) {
        if ([url.host isEqualToString:@"oauth"] || [url.host isEqualToString:@"pay"]) {
            return NO;
        }
        NSData *data = [[UIPasteboard generalPasteboard] dataForPasteboardType:@"content"];
        if (data.length) {
            NSError *serError = nil;
            NSDictionary *dic = [NSPropertyListSerialization propertyListWithData:data options:0 format:0 error:&serError];
            if (!serError) {
                dic = dic[appid];
                NSInteger code = [dic[@"result"] intValue];
                NSInteger command = [dic[@"command"] intValue];
                if (command < 1000) {
                    return NO;
                }
                if (code == 0) {
                    !self.completion ?: self.completion(YES, dic, nil);
                    self.completion = nil;
                } else {
                    switch (code) {
                        case -2:
                            code = ASKErrorCancelled;
                            break;
                        case -3:
                            code = ASKErrorFailed;
                            break;
                            
                        default:
                            code = ASKErrorUnknown;
                            break;
                    }
                    [self handleErrorWithCode:code userInfo:dic];
                }
            } else {
                [self handleErrorWithCode:ASKErrorSerializeFailure userInfo:serError.userInfo];
            }
        } else {
            NSDictionary *userInfo = @{@"message" : @"response is missing"};
            [self handleErrorWithCode:ASKErrorUnknown userInfo:userInfo];
        }
        return YES;
    }else{
        return NO;
    }
}

+ (void)launchMiniProgramWithName:(NSString *)name path:(NSString *)path miniProgramType:(ASKShareWechatLaunchMiniProgramType)type completion:(ASKCompletionHandler)completion {
    if ([ASKService isRegisteredForType:ASKRegisterTypeWechat]) {
        if ([ASKService isInstalledForType:ASKRegisterTypeWechat]) {
            if (!name) {
                NSDictionary *userInfo = @{@"message" : @"nimiprogram id is needed"};
                NSError *error = [NSError ask_errorWithCode:ASKErrorUnsupportedParams userInfo:userInfo];
                !completion ?: completion(NO, nil, error);
            } else {
                self.completion = completion;
                NSString *launch = [NSString stringWithFormat:@"weixin://app/%@/jumpWxa/?userName=%@&path=%@&miniProgramType=%lud&supportcontentfromwx=8191",[ASKService appidForType:ASKRegisterTypeWechat], name, path, (unsigned long)type];
                NSURL *url = [NSURL URLWithString:launch];
                [[UIApplication sharedApplication] openURL:url];
            }
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

+ (NSURL *)shareURLWithType:(ASKShareToType)type message:(ASKShareMessage *)message {
    NSInteger shareTo = type - 101;
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"result" : @"1",
                                                                               @"returnFromApp" : @"0",
                                                                               @"scene" : @(shareTo).stringValue,
                                                                               @"sdkver" : @"1.8.2"}];
    
    if (message.text) {
        //文本分享
        dic[@"command"] = @"1020";
        dic[@"title"] = message.text;
    } else if (!message.text && message.image) {
        //单图分享
        dic[@"command"] = @"1010";
        dic[@"miniprogramType"] = @0;
        dic[@"withShareTicket"] = @(NO);
        dic[@"messageExt"] = @"";
        dic[@"messageAction"] = @"<action>dotalist</action>";
        dic[@"mediaTagName"] = @"WECHAT_TAG_JUMP_APP";
        dic[@"objectType"] = @"2";
        dic[@"thumbData"] = [ASKUtility dataWithImage:message.image scale:CGSizeMake(100, 100)];
        dic[@"fileData"] = [ASKUtility dataWithImage:message.image];
    } else if (!message.text && !message.image && message.link) {
        //链接分享
        NSString *objectType = nil;
        switch (message.multimediaType) {
            case ASKShareMultimediaTypeAudio:
            {
                dic[@"mediaDataUrl"] = message.mediaDataUrl;
                objectType = @"3";
            }
                break;
            case ASKShareMultimediaTypeVideo:
                objectType = @"4";
                break;
            default:
                objectType = @"5";
                break;
        }
        dic[@"command"] = @"1010";
        dic[@"miniprogramType"] = @0;
        dic[@"withShareTicket"] = @(NO);
        dic[@"objectType"] = objectType;
        dic[@"title"] = message.title;
        dic[@"description"] = message.desc;
        dic[@"mediaUrl"] = message.link;
        dic[@"thumbData"] = [ASKUtility dataWithImage:message.thumbnail scale:CGSizeMake(100, 100)];
    } else if (!message.text && !message.image && message.fileData) {
        //文件分享
        if (type == ASKShareToWechatTimeline) {
            NSDictionary *userInfo = @{@"message" : @"File cannot be shared to timeline"};
            [self handleErrorWithCode:ASKErrorUnsupportedParams userInfo:userInfo];
            return nil;
        }
        dic[@"command"] = @"1010";
        dic[@"miniprogramType"] = @0;
        dic[@"withShareTicket"] = @(NO);
        dic[@"objectType"] = @"6";
        dic[@"title"] = [NSString stringWithFormat:@"%@.%@", message.fileName ?: @"", message.fileExt ?: @""];
        dic[@"description"] = message.desc;
        dic[@"fileExt"] = message.fileExt;
        dic[@"fileData"] = message.fileData;
        dic[@"thumbData"] = [ASKUtility dataWithImage:message.thumbnail scale:CGSizeMake(100, 100)];
    } else {
        NSDictionary *userInfo = @{@"message" : @"Wechat can only be shared to with text, image, link, fileData"};
        [self handleErrorWithCode:ASKErrorUnsupportedParams userInfo:userInfo];
        return nil;
    }
    NSError *serError = nil;
    NSString *appid = [ASKService appidForType:ASKRegisterTypeWechat];
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:@{appid : dic} format:NSPropertyListBinaryFormat_v1_0 options:0 error:&serError];
    if (!serError) {
        [[UIPasteboard generalPasteboard] setData:data forPasteboardType:@"content"];
        NSString *link = [NSString stringWithFormat:@"weixin://app/%@/sendreq/?&supportcontentfromwx=8191",appid];
        return [NSURL URLWithString:link];
    } else {
        [self handleErrorWithCode:ASKErrorSerializeFailure userInfo:serError.userInfo];
        return nil;
    }
}


@end
