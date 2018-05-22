//
//  NSError+ASKExtend.h
//  AgileSocialKit
//
//  Created by 周夏赛 on 2018/5/21.
//

#import <Foundation/Foundation.h>

extern NSErrorDomain const ASKErrorDomain;

typedef NS_ERROR_ENUM(ASKErrorDomain,ASKErrorCode) {
    ASKErrorUnknown                 = -1,
    ASKErrorUnsupportedType         = 1,
    ASKErrorUnsupportedParams       = 2,
    ASKErrorSerializeFailure        = 3,
    ASKErrorPhotosAccessDenied      = 4,
    
    ASKErrorUnregistered            = 5,
    ASKErrorUninstalled             = 6,
    ASKErrorCancelled               = 7,
    ASKErrorFailed                  = 8
};



@interface NSError (ASKExtend)

+ (instancetype)ask_errorWithCode:(ASKErrorCode)code userInfo:(NSDictionary *)userInfo;

@end
