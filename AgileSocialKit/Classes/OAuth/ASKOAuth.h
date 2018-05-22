//
//  ASKOAuth.h
//  AgileSocialKit
//
//  Created by 周夏赛 on 2018/5/21.
//

#import <Foundation/Foundation.h>
#import "ASKItem.h"

@class ASKOAuthInfo;

typedef NS_ENUM(NSUInteger, ASKOAuthType) {
    ASKOAuthTypeWechat      = 101,
};

@protocol ASKOAuthProtocol <NSObject>

@required
+ (void)authWithInfo:(ASKOAuthInfo *)info completion:(ASKCompletionHandler)completion;
+ (BOOL)handleOpenURL:(NSURL *)url;

@end

@interface ASKOAuth : NSObject <ASKServiceProtocol>


+ (void)authWithType:(ASKOAuthType)type authInfo:(ASKOAuthInfo *)info completion:(ASKCompletionHandler)completion;

@end

@interface ASKOAuthInfo : NSObject

///微信
@property (nonatomic, copy) NSString *scope;
///支付宝
@property (nonatomic, copy) NSString *authInfo;
///支付宝
@property (nonatomic, copy) NSString *scheme;

+ (instancetype)wechatAuthInfoWithScope:(NSString *)scope;
+ (instancetype)alipayAuthInfoWithAuthInfo:(NSString *)authInfo scheme:(NSString *)scheme;

@end
