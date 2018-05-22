//
//  ASKShareDingTalk.h
//  AgileSocialKit
//
//  Created by 周夏赛 on 2018/5/21.
//

#import "ASKItem.h"
#import "ASKShare.h"

@interface ASKShareDingTalk : ASKItem <ASKShareProtocol>

@end

#pragma mark - ASKAgileShareDingTalkModel -

@class ASKShareDingTalkMediaMessage;


/**
 分享SDK请求类的基类.
 */
@interface ASKShareDingTalkBaseReq : NSObject <NSCoding>
///向钉钉注册的 appId
@property (nonatomic, copy) NSString *appId;
///bundleId
@property (nonatomic, copy) NSString *appBundleIdentifier;

@end

@interface ASKShareDingTalkSendMessageToDingTalkReq : ASKShareDingTalkBaseReq

/// 向钉钉发送的消息.
@property (nonatomic, strong) ASKShareDingTalkMediaMessage *message;
/// 向钉钉发送消息的场景.
@property (nonatomic, assign) NSInteger scene;

@end


@interface ASKShareDingTalkMediaMessage : NSObject <NSCoding>

/// 标题. @note 长度不超过 512Byte.
@property (nonatomic, copy) NSString *title;
/// 描述内容. @note 长度不超过 1K.
@property (nonatomic, copy) NSString *messageDescription;

/// 缩略图数据. @note 长度不超过 32K.
@property (nonatomic, strong) NSData *thumbData;

/// 缩略图URL. @note 长度不超过 10K.
@property (nonatomic, copy) NSString *thumbURL;

/// 多媒体数据对象. 可以为DTMediaTextObject, DTMediaImageObject, DTMediaWebObject等.
@property (nonatomic, strong) id mediaObject;

@end

/**
 多文本消息中的文本对象.
 */
@interface ASKShareDingTalkMediaTextObject : NSObject <NSCoding>

/// 文本内容. @note 长度不超过 1K.
@property (nonatomic, copy) NSString *text;

@end

/**
 多文本消息中的图片对象.
 */
@interface ASKShareDingTalkMediaImageObject : NSObject <NSCoding>

/// 图片内容. @note 大小不能超过 10M.
@property (nonatomic, strong) NSData *imageData;

/// 图片URL. @note 长度不能超过 10K.
@property (nonatomic, copy) NSString *imageURL;

@end

/**
 多文本消息中的Web页面对象.
 */
@interface ASKShareDingTalkMediaWebObject : NSObject <NSCoding>

/// Web页面的URL. @note 长度不能超过 10K.
@property (nonatomic, copy) NSString *pageURL;

@end


/**
 分享SDK响应类的基类.
 */
@interface ASKShareDingTalkBaseResp : NSObject <NSCoding>

/// 错误码.
@property (nonatomic, assign) NSInteger errorCode;
/// 错误提示.
@property (nonatomic, copy) NSString *errorMessage;

@end
