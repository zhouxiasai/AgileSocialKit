//
//  AgileSocialKit.h
//  Pods
//
//  Created by CaydenK on 2017/11/10.
//

#ifndef AgileSocialKit_h
#define AgileSocialKit_h

#import <Foundation/Foundation.h>

#define ASK_CONTAIN_BASE   __has_include("ASKMacro.h")
#define ASK_CONTAIN_SHARE   __has_include("ASKShareKit.h")
#define ASK_CONTAIN_OAUTH   __has_include("ASKOAuthKit.h")
#define ASK_CONTAIN_PAY     __has_include("ASKPayKit.h")

#if ASK_CONTAIN_BASE
#import "ASKMacro.h"
#endif

#if ASK_CONTAIN_SHARE
#import "ASKShareKit.h"
#endif

#if ASK_CONTAIN_OAUTH
#import "ASKOAuthKit.h"
#endif

#if ASK_CONTAIN_PAY
#import "ASKPayKit.h"
#endif

#endif /* AgileSocialKit_h */
