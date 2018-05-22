//
//  ASKPay.m
//  AgileSocialKit
//
//  Created by 周夏赛 on 2018/5/21.
//

#import "ASKPay.h"

@implementation ASKPay

+ (void)payWithType:(ASKPayType)type payInfo:(ASKPayInfo *)info completion:(ASKCompletionHandler)completion {
    Class<ASKPayProtocol> cls = [self classWithType:type];
    if (cls) {
        [cls payWithInfo:info completion:completion];
    } else {
        NSError *error = [NSError ask_errorWithCode:ASKErrorUnsupportedType userInfo:@{@"message" : @"Unsupported pay type"}];
        !completion ?: completion(NO, nil, error);
    }
}

+ (BOOL)handleOpenURL:(NSURL *)url {
    Class<ASKPayProtocol> cls = nil;
    
    cls = NSClassFromString(@"ASKPayWechat");
    if ([cls handleOpenURL:url]) return YES;
    
    return NO;
}

+ (Class<ASKPayProtocol>)classWithType:(ASKPayType)type {
    NSUInteger i = type / 100;
    NSString *clsName = nil;
    switch (i) {
        case 1:
            clsName = @"ASKPayWechat";
            break;
            
        default:
            return nil;
            break;
    }
    return NSClassFromString(clsName);
}

@end


@implementation ASKPayInfo

+ (ASKPayInfoWechat *)wechatPayInfoWithPartnerId:(NSString *)partnerId prepayId:(NSString *)prepayId nonceStr:(NSString *)nonceStr timeStamp:(UInt32)timeStamp package:(NSString *)package sign:(NSString *)sign {
    ASKPayInfoWechat *wechat = [[ASKPayInfoWechat alloc] init];
    wechat.partnerId = partnerId;
    wechat.prepayId = prepayId;
    wechat.nonceStr = nonceStr;
    wechat.timeStamp = timeStamp;
    wechat.package = package;
    wechat.sign = sign;
    return wechat;
}

+ (ASKPayInfoAlipay *)alipayPayInfoWithPayUrl:(NSString *)payUrl scheme:(NSString *)scheme {
    ASKPayInfoAlipay *alipay = [[ASKPayInfoAlipay alloc] init];
    alipay.payUrl = payUrl;
    alipay.scheme = scheme;
    return alipay;
}


@end

@implementation ASKPayInfoWechat

- (NSString *)toString {
    return [NSString stringWithFormat:@"nonceStr=%@&package=%@&partnerId=%@&prepayId=%@&timeStamp=%ud&sign=%@&signType=SHA1", self.nonceStr, self.package, self.partnerId, self.prepayId, (unsigned int)self.timeStamp, self.sign];
}

@end

@implementation ASKPayInfoAlipay

@end
