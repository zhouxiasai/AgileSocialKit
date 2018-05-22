//
//  ASKItem.h
//  AgileSocialKit
//
//  Created by 周夏赛 on 2018/5/21.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "NSError+ASKExtend.h"
#import "ASKService.h"

typedef void(^ASKCompletionHandler)(BOOL success, id ret, NSError *error);

@interface ASKItem : NSObject

@property (class, copy, nonatomic) ASKCompletionHandler completion;

+ (void)handleErrorWithCode:(ASKErrorCode)code userInfo:(NSDictionary *)userInfo;

@end
