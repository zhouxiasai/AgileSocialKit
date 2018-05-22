//
//  ASKShareQQ.m
//  AgileSocialKit
//
//  Created by 周夏赛 on 2018/5/21.
//

#import "ASKShareQQ.h"

NSInteger const ASKQQEnumMapping[] = {
    [ASKShareToQQFriends]    = 0,    //QQ好友
    [ASKShareToQQZone]       = 0x01, //QQ空间
    [ASKShareToQQFavorites]  = 0x08, //收藏
    [ASKShareToQQDataline]   = 0x10, //数据线
};

@implementation ASKShareQQ

+ (void)shareToType:(ASKShareToType)type message:(ASKShareMessage *)message completion:(ASKCompletionHandler)completion {
    if ([ASKService isRegisteredForType:ASKRegisterTypeQQ]) {
        if ([ASKService isInstalledForType:ASKRegisterTypeQQ]) {
            self.completion = completion;
            NSURL *url = [self shareURLWithType:type message:message];
            if (!url) return;
            [[UIApplication sharedApplication] openURL:url];
        } else {
            NSDictionary *userInfo = @{@"message" : @"QQ uninstalled"};
            NSError *error = [NSError ask_errorWithCode:ASKErrorUninstalled userInfo:userInfo];
            !completion ?: completion(NO, nil, error);
        }
    } else {
        NSDictionary *userInfo = @{@"message" : @"please register QQ with appId before you can share to it"};
        NSError *error = [NSError ask_errorWithCode:ASKErrorUnregistered userInfo:userInfo];
        !completion ?: completion(NO, nil, error);
    }
}

+ (BOOL)handleOpenURL:(NSURL *)url {
    NSString *appid = [ASKService appidForType:ASKRegisterTypeQQ];
    if ([url.scheme isEqualToString:[@"tecent" stringByAppendingString:appid]] ||
        [url.scheme isEqualToString:[NSString stringWithFormat:@"QQ%08llx", appid.longLongValue]]) {
        if (![url.host isEqualToString:@"response_from_qq"]) {
            return NO;
        }
        
        NSMutableDictionary *dic = [ASKUtility parseUrl:url];
        NSInteger code = [[dic objectForKey:@"error"] integerValue];
        if (code == 0) {
            !self.completion ?: self.completion(YES, nil, nil);
            self.completion = nil;
        } else {
            switch (code) {
                case -1:
                    code = ASKErrorFailed;
                    break;
                case -4:
                    code = ASKErrorCancelled;
                    break;
                    
                default:
                    code = ASKErrorUnknown;
                    break;
            }
            if (dic[@"error_description"]) {
                dic[@"error_description"] = [ASKUtility base64Decode:dic[@"error_description"]];
            }
            [self handleErrorWithCode:code userInfo:dic.copy];
        }
        return YES;
    } else {
        return NO;
    }
}

+ (NSURL *)shareURLWithType:(ASKShareToType)type message:(ASKShareMessage *)message {
    NSString *appid = [ASKService appidForType:ASKRegisterTypeQQ];
    NSMutableString *ret = [[NSMutableString alloc] initWithString:@"mqqapi://share/to_fri?"];
    [ret appendFormat:@"thirdAppDisplayName=%@", [ASKUtility base64Encode:[ASKUtility bundleDisplayName]]];
    [ret appendString:@"&version=1"];
    [ret appendFormat:@"&cflag=%ld",(long)ASKQQEnumMapping[type]];
    [ret appendString:@"&callback_type=scheme"];
    [ret appendString:@"&generalpastboard=1"];
    [ret appendFormat:@"&callback_name=QQ%08llx", appid.longLongValue];
    [ret appendString:@"&src_type=app"];
    [ret appendString:@"&shareType=0"];
    [ret appendString:@"&sdkv=3.3.1"];
    
    NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
    if (message.text) {
        //纯文本分享
        [ret appendString:@"&file_type=text"];
        [ret appendFormat:@"&file_data=%@", [ASKUtility urlEncode:[ASKUtility base64Encode:message.text]]];
        if (type == ASKShareToQQZone) {
            NSDictionary *userInfo = @{@"message" : @"Text cannot be shared to QQZone"};
            [self handleErrorWithCode:ASKErrorUnsupportedParams userInfo:userInfo];
            return nil;
        }
    } else if (!message.text && message.image) {
        //图片分享
        [ret appendString:@"&file_type=img"];
        [ret appendFormat:@"&title=%@", @""];
        [ret appendFormat:@"&description=%@", @""];
        [ret appendString:@"&objectlocation=pasteboard"];
        
        [mDic addEntriesFromDictionary:@{@"file_data" : [ASKUtility dataWithImage:message.image],
                                         @"previewimagedata" : [ASKUtility dataWithImage:message.image scale:CGSizeMake(100, 100)],
                                         }];
    } else if (!message.text && !message.image && message.link) {
        //链接分享
        NSString *messageType = nil;
        switch (message.multimediaType) {
            case ASKShareMultimediaTypeAudio:
                messageType = @"&file_type=audio";
                break;
            case ASKShareMultimediaTypeVideo:
                messageType = @"&file_type=video";
                break;
            default:
                messageType = @"&file_type=news";
                break;
        }
        [ret appendString:messageType];
        if (message.mediaDataUrl) {
            [ret appendFormat:@"&flashurl=%@", [ASKUtility urlEncode:[ASKUtility base64Encode:message.mediaDataUrl]]];
        }
        [ret appendFormat:@"&url=%@", [ASKUtility urlEncode:[ASKUtility base64Encode:message.link]]];
        [ret appendFormat:@"&title=%@", [ASKUtility urlEncode:[ASKUtility base64Encode:message.title ?: @""]]];
        [ret appendFormat:@"&description=%@", [ASKUtility urlEncode:[ASKUtility base64Encode:message.desc ?: @""]]];
        [ret appendString:@"&objectlocation=pasteboard"];
        
        [mDic addEntriesFromDictionary:@{@"previewimagedata" : [ASKUtility dataWithImage:message.thumbnail scale:CGSizeMake(100, 100)]}];
    } else if (!message.text && !message.image && message.fileData) {
        //文件分享
        if (type == ASKShareToQQZone) {
            NSDictionary *userInfo = @{@"message" : @"File cannot be shared to QQZone"};
            [self handleErrorWithCode:ASKErrorUnsupportedParams userInfo:userInfo];
            return nil;
        }
        [ret appendString:@"&file_type=localFile"];
        [ret appendFormat:@"&fileName=%@", [NSString stringWithFormat:@"%@.%@", message.fileName ?: @"", message.fileExt ?: @""]];
        [ret appendFormat:@"&title=%@", [ASKUtility urlEncode:[ASKUtility base64Encode:message.title ?: @""]]];
        [ret appendFormat:@"&description=%@", [ASKUtility urlEncode:[ASKUtility base64Encode:message.desc ?: @""]]];
        [ret appendString:@"&objectlocation=pasteboard"];
        
        [mDic addEntriesFromDictionary:@{@"file_data" : message.fileData ?: [NSData data]}];
    } else {
        NSDictionary *userInfo = @{@"message" : @"QQ can only be shared to with text, image, link, fileData"};
        [self handleErrorWithCode:ASKErrorUnsupportedParams userInfo:userInfo];
        return nil;
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:mDic];
    [[UIPasteboard generalPasteboard] setData:data forPasteboardType:@"com.tencent.mqq.api.apiLargeData"];
    NSURL *url = [NSURL URLWithString:ret];
    return url;
}

@end
