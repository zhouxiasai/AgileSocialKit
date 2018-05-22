//
//  ASKShareDingTalk.m
//  AgileSocialKit
//
//  Created by 周夏赛 on 2018/5/21.
//

#import "ASKShareDingTalk.h"

@implementation ASKShareDingTalk

+ (void)initialize {
    [NSKeyedArchiver setClassName:@"DTBaseReq" forClass:[ASKShareDingTalkBaseReq class]];
    [NSKeyedArchiver setClassName:@"DTSendMessageToDingTalkReq" forClass:[ASKShareDingTalkSendMessageToDingTalkReq class]];
    [NSKeyedArchiver setClassName:@"DTMediaMessage" forClass:[ASKShareDingTalkMediaMessage class]];
    [NSKeyedArchiver setClassName:@"DTMediaTextObject" forClass:[ASKShareDingTalkMediaTextObject class]];
    [NSKeyedArchiver setClassName:@"DTMediaImageObject" forClass:[ASKShareDingTalkMediaImageObject class]];
    [NSKeyedArchiver setClassName:@"DTMediaWebObject" forClass:[ASKShareDingTalkMediaWebObject class]];
    [NSKeyedArchiver setClassName:@"DTBaseResp" forClass:[ASKShareDingTalkBaseResp class]];
    
    [NSKeyedUnarchiver setClass:[ASKShareDingTalkBaseReq class] forClassName:@"DTBaseReq"];
    [NSKeyedUnarchiver setClass:[ASKShareDingTalkSendMessageToDingTalkReq class] forClassName:@"DTSendMessageToDingTalkReq"];
    [NSKeyedUnarchiver setClass:[ASKShareDingTalkMediaMessage class] forClassName:@"DTMediaMessage"];
    [NSKeyedUnarchiver setClass:[ASKShareDingTalkMediaTextObject class] forClassName:@"DTMediaTextObject"];
    [NSKeyedUnarchiver setClass:[ASKShareDingTalkMediaImageObject class] forClassName:@"DTMediaImageObject"];
    [NSKeyedUnarchiver setClass:[ASKShareDingTalkMediaWebObject class] forClassName:@"DTMediaWebObject"];
    [NSKeyedUnarchiver setClass:[ASKShareDingTalkBaseResp class] forClassName:@"DTBaseResp"];
}

+ (void)shareToType:(ASKShareToType)type message:(ASKShareMessage *)message completion:(ASKCompletionHandler)completion {
    if ([ASKService isRegisteredForType:ASKRegisterTypeWeibo]) {
        if ([ASKService isInstalledForType:ASKRegisterTypeWeibo]) {
            self.completion = completion;
            NSURL *url = [self shareURLWithType:type message:message];
            if (!url) return;
            [[UIApplication sharedApplication] openURL:url];
        } else {
            NSDictionary *userInfo = @{@"message" : @"DingTalk uninstalled"};
            NSError *error = [NSError ask_errorWithCode:ASKErrorUninstalled userInfo:userInfo];
            !completion ?: completion(NO, nil, error);
        }
    } else {
        NSDictionary *userInfo = @{@"message" : @"please register DingTalk with appId before you can use it"};
        NSError *error = [NSError ask_errorWithCode:ASKErrorUnregistered userInfo:userInfo];
        !completion ?: completion(NO, nil, error);
    }
}

+ (BOOL)handleOpenURL:(NSURL *)url {
    NSString *appid = [ASKService appidForType:ASKRegisterTypeDingTalk];
    if ([url.scheme isEqualToString:appid]) {
        NSString *pbType = [NSString stringWithFormat:@"com.dingtalk.openapi.resp.%@", appid];
        NSData *data = [[UIPasteboard generalPasteboard] dataForPasteboardType:pbType];
        ASKShareDingTalkBaseResp *resp = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (resp) {
            NSInteger code = resp.errorCode;
            if (code == 0) {
                !self.completion ?: self.completion(YES, nil, nil);
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
                NSDictionary *userInfo = @{@"message" : resp.errorMessage ?: @"unknown error"};
                [self handleErrorWithCode:code userInfo:userInfo];
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

+ (NSURL *)shareURLWithType:(ASKShareToType)type message:(ASKShareMessage *)message {
    NSString *appid = [ASKService appidForType:ASKRegisterTypeDingTalk];
    ASKShareDingTalkSendMessageToDingTalkReq *req = [[ASKShareDingTalkSendMessageToDingTalkReq alloc] init];
    req.appId = appid;
    req.appBundleIdentifier = [ASKUtility bundleIdentifier];
    if (message.text) {
        //文本分享
        ASKShareDingTalkMediaTextObject *object = [[ASKShareDingTalkMediaTextObject alloc] init];
        object.text = message.text;
        req.message.mediaObject = object;
    } else if (!message.text && message.image) {
        //单图分享
        ASKShareDingTalkMediaImageObject *object = [[ASKShareDingTalkMediaImageObject alloc] init];
        object.imageData = [ASKUtility dataWithImage:message.image];
        req.message.mediaObject = object;
    } else if (!message.text && !message.image && message.link) {
        //链接分享
        req.message.title = message.title ?: @"";
        req.message.messageDescription = message.desc ?: @"";
        req.message.thumbData = [ASKUtility dataWithImage:message.thumbnail scale:CGSizeMake(100, 100)];
        ASKShareDingTalkMediaWebObject *object = [[ASKShareDingTalkMediaWebObject alloc] init];
        object.pageURL = message.link;
        req.message.mediaObject = object;
    } else {
        NSDictionary *userInfo = @{@"message" : @"DingTalk can only be shared to with text, image, link"};
        [self handleErrorWithCode:ASKErrorUnsupportedParams userInfo:userInfo];
        return nil;
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:req];
    NSString *pbType = [NSString stringWithFormat:@"com.dingtalk.openapi.req.%@", appid];
    [[UIPasteboard generalPasteboard] setData:data forPasteboardType:pbType];
    NSString *link = [NSString stringWithFormat:@"dingtalk-open://openapi/sendMessage?appId=%@&action=sendReq", appid];
    NSURL *url = [NSURL URLWithString:link];
    return url;
}

@end


#pragma mark - ASKAgileShareDingTalkModelImplement

@implementation ASKShareDingTalkBaseReq {
    NSInteger _reqType;
    NSString *_openSDKVersion;
}

- (instancetype)init {
    if (self = [super init]) {
        _reqType = 1;
        _openSDKVersion = @"2.0.0";
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:_reqType forKey:@"reqType"];
    [aCoder encodeObject:_openSDKVersion forKey:@"openSDKVersion"];
    [aCoder encodeObject:self.appId forKey:@"appId"];
    [aCoder encodeObject:self.appBundleIdentifier forKey:@"appBundleIdentifier"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _reqType = [aDecoder decodeIntegerForKey:@"reqType"];
        _openSDKVersion = [aDecoder decodeObjectForKey:@"openSDKVersion"];
        _appId = [aDecoder decodeObjectForKey:@"appId"];
        _appBundleIdentifier = [aDecoder decodeObjectForKey:@"appBundleIdentifier"];
    }
    return self;
}

@end

@implementation ASKShareDingTalkSendMessageToDingTalkReq

- (instancetype)init {
    if (self = [super init]) {
        _message = [[ASKShareDingTalkMediaMessage alloc] init];
        _scene = 0;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeInteger:_scene forKey:@"scene"];
    [aCoder encodeObject:_message forKey:@"message"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _scene = [aDecoder decodeIntegerForKey:@"scene"];
        _message = [aDecoder decodeObjectForKey:@"message"];
    }
    return self;
}


@end

@implementation ASKShareDingTalkMediaMessage {
    NSInteger _messageType;
}

- (instancetype)init {
    if (self = [super init]) {
        _title = @"";
        _messageDescription = @"";
        _thumbURL = @"";
        _thumbData = [NSData data];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:_messageType forKey:@"messageType"];
    [aCoder encodeObject:_title forKey:@"title"];
    [aCoder encodeObject:_messageDescription forKey:@"messageDescription"];
    [aCoder encodeObject:_thumbData forKey:@"thumbData"];
    [aCoder encodeObject:_thumbURL forKey:@"thumbURL"];
    [aCoder encodeObject:_mediaObject forKey:@"mediaObject"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _title = [aDecoder decodeObjectForKey:@"title"];
        _messageDescription = [aDecoder decodeObjectForKey:@"messageDescription"];
        _thumbData = [aDecoder decodeObjectForKey:@"thumbData"];
        _thumbURL = [aDecoder decodeObjectForKey:@"thumbURL"];
        _mediaObject = [aDecoder decodeObjectForKey:@"mediaObject"];
        _messageType = [aDecoder decodeIntegerForKey:@"messageType"];
    }
    return self;
}

- (void)setMediaObject:(id)mediaObject {
    _mediaObject = mediaObject;
    if ([mediaObject isKindOfClass:[ASKShareDingTalkMediaWebObject class]]) {
        _messageType = 1;
    } else if ([mediaObject isKindOfClass:[ASKShareDingTalkMediaTextObject class]]) {
        _messageType = 2;
    } else if ([mediaObject isKindOfClass:[ASKShareDingTalkMediaImageObject class]]) {
        _messageType = 3;
    }
}

@end

@implementation ASKShareDingTalkMediaTextObject

- (instancetype)init {
    if (self = [super init]) {
        _text = @"";
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_text forKey:@"text"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _text = [aDecoder decodeObjectForKey:@"text"];
    }
    return self;
}

@end

@implementation ASKShareDingTalkMediaImageObject

- (instancetype)init {
    if (self = [super init]) {
        _imageURL = @"";
        _imageData = [NSData data];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_imageURL forKey:@"imageURL"];
    [aCoder encodeObject:_imageData forKey:@"imageData"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _imageURL = [aDecoder decodeObjectForKey:@"imageURL"];
        _imageData = [aDecoder decodeObjectForKey:@"imageData"];
    }
    return self;
}

@end

@implementation ASKShareDingTalkMediaWebObject

- (instancetype)init {
    if (self = [super init]) {
        _pageURL = @"";
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_pageURL forKey:@"pageURL"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _pageURL = [aDecoder decodeObjectForKey:@"pageURL"];
    }
    return self;
}

@end

@implementation ASKShareDingTalkBaseResp {
    NSInteger _reqType;
    NSString *_appId;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:_reqType forKey:@"reqType"];
    [aCoder encodeObject:_appId forKey:@"appId"];
    [aCoder encodeInteger:_errorCode forKey:@"errorCode"];
    [aCoder encodeObject:_errorMessage forKey:@"errorMessage"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _reqType = [aDecoder decodeIntegerForKey:@"reqType"];
        _appId = [aDecoder decodeObjectForKey:@"appId"];
        _errorCode = [aDecoder decodeIntegerForKey:@"errorCode"];
        _errorMessage = [aDecoder decodeObjectForKey:@"errorMessage"];
    }
    return self;
}

@end
