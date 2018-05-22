//
//  NSError+ASKExtend.m
//  AgileSocialKit
//
//  Created by 周夏赛 on 2018/5/21.
//

#import "NSError+ASKExtend.h"

NSErrorDomain const ASKErrorDomain = @"ASKErrorDomain";

@implementation NSError (ASKExtend)

+ (instancetype)ask_errorWithCode:(ASKErrorCode)code userInfo:(NSDictionary *)userInfo {
    return [NSError errorWithDomain:ASKErrorDomain code:code userInfo:userInfo];
}

@end
