//
//  ASKPay.h
//  AgileSocialKit
//
//  Created by 周夏赛 on 2018/5/21.
//

#import <Foundation/Foundation.h>
#import "ASKItem.h"

@class ASKPayInfo;
@class ASKPayInfoWechat;
@class ASKPayInfoAlipay;

typedef NS_ENUM(NSUInteger, ASKPayType) {
    ASKPayTypeWechat      = 101,
};


@protocol ASKPayProtocol <NSObject>

@required
+ (void)payWithInfo:(ASKPayInfo *)info completion:(ASKCompletionHandler)completion;
+ (BOOL)handleOpenURL:(NSURL *)url;

@end

@interface ASKPay : NSObject <ASKServiceProtocol>

+ (void)payWithType:(ASKPayType)type payInfo:(ASKPayInfo *)info completion:(ASKCompletionHandler)completion;

@end


@interface ASKPayInfo : NSObject

+ (ASKPayInfoWechat *)wechatPayInfoWithPartnerId:(NSString *)partnerId prepayId:(NSString *)prepayId nonceStr:(NSString *)nonceStr timeStamp:(UInt32)timeStamp package:(NSString *)package sign:(NSString *)sign;
+ (ASKPayInfoAlipay *)alipayPayInfoWithPayUrl:(NSString *)payUrl scheme:(NSString *)scheme;

@end

@interface ASKPayInfoWechat : ASKPayInfo

/** 商家向财付通申请的商家id */
@property (nonatomic, retain) NSString *partnerId;
/** 预支付订单 */
@property (nonatomic, retain) NSString *prepayId;
/** 随机串，防重发 */
@property (nonatomic, retain) NSString *nonceStr;
/** 时间戳，防重发 */
@property (nonatomic, assign) UInt32 timeStamp;
/** 商家根据财付通文档填写的数据和签名 */
@property (nonatomic, retain) NSString *package;
/** 商家根据微信开放平台文档对数据做的签名 */
@property (nonatomic, retain) NSString *sign;

- (NSString *)toString;

@end


@interface ASKPayInfoAlipay : ASKPayInfo

@property (nonatomic, copy) NSString *payUrl;
@property (nonatomic, copy) NSString *scheme;

@end
