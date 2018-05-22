//
//  ASKAppDelegate.m
//  AgileSocialKit
//
//  Created by 紫芋 on 05/22/2018.
//  Copyright (c) 2018 紫芋. All rights reserved.
//

#import "ASKAppDelegate.h"
#import "AgileSocialKit.h"

@implementation ASKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [ASKService registerWithAppid:@"1106159299" forType:ASKRegisterTypeQQ];
    [ASKService registerWithAppid:@"wx54ea8047c0d273a6" forType:ASKRegisterTypeWechat];
    [ASKService registerWithAppid:@"1253521415" forType:ASKRegisterTypeWeibo];
    [ASKService registerWithAppid:@"dingoak5hqhuvmpfhpnjvt" forType:ASKRegisterTypeDingTalk];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self sourceAppApplicationCallBackWithURL:url];
}

// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
    return [self sourceAppApplicationCallBackWithURL:url];
}

- (BOOL)sourceAppApplicationCallBackWithURL:(NSURL *)url {
    return [ASKService handleOpenURL:url];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
