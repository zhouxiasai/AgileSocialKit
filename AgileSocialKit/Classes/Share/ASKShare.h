//
//  ASKShare.h
//  AgileSocialKit
//
//  Created by 周夏赛 on 2018/5/21.
//

#import <Foundation/Foundation.h>
#import "ASKItem.h"

@class ASKShareMessage;

typedef NS_ENUM(NSUInteger, ASKShareToType) {
    ASKShareToLocalAlbum         = 1,
    ASKShareToPasteboard         = 2,

    ASKShareToWechatSession      = 101,
    ASKShareToWechatTimeline     = 102,
    ASKShareToWechatFavorite     = 103,

    ASKShareToQQFriends          = 201,
    ASKShareToQQZone             = 202,
    ASKShareToQQFavorites        = 203,
    ASKShareToQQDataline         = 204,

    ASKShareToWeiboHome          = 301,

    ASKShareToDingTalkSession    = 501,
};


@protocol ASKShareProtocol <NSObject>

@required
+ (void)shareToType:(ASKShareToType)type message:(ASKShareMessage *)message completion:(ASKCompletionHandler)completion;
+ (BOOL)handleOpenURL:(NSURL *)url;

@end

@interface ASKShare : NSObject <ASKServiceProtocol>

+ (void)shareToType:(ASKShareToType)type message:(ASKShareMessage *)message completion:(ASKCompletionHandler)completion;

@end



typedef NS_ENUM(NSUInteger, ASKShareMultimediaType) {
    ASKShareMultimediaTypeNews,
    ASKShareMultimediaTypeAudio,
    ASKShareMultimediaTypeVideo,
    ASKShareMultimediaTypeFile,
    ASKShareMultimediaTypeUndefined
};

/**
 基本消息类型
 
 */
@interface ASKShareMessage : NSObject

///文本, 高优先级，有值则为纯文本消息，微博分享可以加图片 image 属性
@property (nonatomic, copy) NSString *text;
///图片，中优先级，有值则为纯图片消息，微博分享可以加文本 text 属性
@property (nonatomic, strong) UIImage *image;
///链接，低优先级，有值则为链接消息，微博分享链接，thumbnail 属性无效
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, strong) UIImage *thumbnail;

//for 微信 & QQ 的链接消息
///微信 QQ 的链接消息优先判断媒体类型, 微信的 audio 类型需要给 mediaDataUrl 赋值
@property (nonatomic, assign) ASKShareMultimediaType multimediaType;
@property (nonatomic, copy)NSString *mediaDataUrl;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, copy)NSString *fileExt;
@property (nonatomic, strong) NSData *fileData;

@end
