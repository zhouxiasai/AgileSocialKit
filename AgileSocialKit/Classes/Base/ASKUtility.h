//
//  ASKUtility.h
//  AgileSocialKit
//
//  Created by 周夏赛 on 2018/5/21.
//

#import <Foundation/Foundation.h>

@interface ASKUtility : NSObject

+ (NSString *)localizedString:(NSString *)input;

//bundle info
+ (NSString *)bundleIdentifier;
+ (NSString *)bundleDisplayName;
+ (NSData *)bundleIconData;

+ (NSData *)dataWithImage:(UIImage *)image;
+ (NSData *)dataWithImage:(UIImage *)image scale:(CGSize)size;

+ (void)saveImageToAlbum:(UIImage *)image completion:(void(^)(BOOL success, NSError *error))completion;
+ (void)copyContentToPasteboard:(NSString *)content;


+ (NSString *)base64Encode:(NSString *)input;
+ (NSString *)base64Decode:(NSString *)input;
+ (NSString *)urlEncode:(NSString *)input;
+ (NSMutableDictionary *)parseUrl:(NSURL *)url;

@end
