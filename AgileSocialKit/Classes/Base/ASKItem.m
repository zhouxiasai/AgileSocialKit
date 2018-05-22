//
//  ASKItem.m
//  AgileSocialKit
//
//  Created by 周夏赛 on 2018/5/21.
//

#import "ASKItem.h"

@implementation ASKItem

+ (ASKCompletionHandler)completion {
    return objc_getAssociatedObject(self, _cmd);
}

+ (void)setCompletion:(ASKCompletionHandler)completion {
    objc_setAssociatedObject(self, @selector(completion), completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (void)handleErrorWithCode:(ASKErrorCode)code userInfo:(NSDictionary *)userInfo {
    NSError *error = [NSError ask_errorWithCode:code userInfo:userInfo];
    !self.completion ?: self.completion(NO, nil, error);
    self.completion = nil;
}


@end
