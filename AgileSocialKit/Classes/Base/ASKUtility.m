//
//  ASKUtility.m
//  AgileSocialKit
//
//  Created by 周夏赛 on 2018/5/21.
//

#import "ASKUtility.h"
#import "NSError+ASKExtend.h"
#import <Photos/Photos.h>

@implementation ASKUtility

+ (NSString *)localizedString:(NSString *)input {
    static NSBundle *localizeBundle = nil;
    if (!localizeBundle) {
        NSBundle *bundle = [NSBundle bundleForClass:[ASKUtility class]];
        NSURL *bundleURL = [bundle URLForResource:@"Localize" withExtension:@"bundle"];
        localizeBundle = [NSBundle bundleWithURL:bundleURL];
    }
    NSString *output = NSLocalizedStringFromTableInBundle(input, @"AgileSocialKit", localizeBundle, nil);
    return output;
}

+ (NSString *)bundleIdentifier {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

+ (NSString *)bundleDisplayName {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *name = [info objectForKey:@"CFBundleDisplayName"] ?: [info objectForKey:@"CFBundleName"];
    return name;
}

+ (NSData *)bundleIconData {
    NSString *iconName = [[[[NSBundle mainBundle] infoDictionary] valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
    UIImage *image = [UIImage imageNamed:iconName];
    NSData *data = image ? UIImageJPEGRepresentation(image, 1) : nil;
    return data;
}


+ (NSData *)dataWithImage:(UIImage *)image {
    return UIImageJPEGRepresentation(image, 1);
}
+ (NSData *)dataWithImage:(UIImage *)image scale:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage *scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return UIImageJPEGRepresentation(scaledImage, 1);
}

+ (void)saveImageToAlbum:(UIImage *)image completion:(void (^)(BOOL, NSError *))completion {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                [self saveImageToAlbum:image completion:completion];
            } else {
                //TODO: localized string
                NSError *error = [NSError ask_errorWithCode:ASKErrorPhotosAccessDenied userInfo:@{@"message" : @"无法访问相册"}];
                completion(NO, error);
            }
        }];
    } else if  (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted) {
        //TODO: localized string
        NSError *error = [NSError ask_errorWithCode:ASKErrorPhotosAccessDenied userInfo:@{@"message" : @"无法访问相册"}];
        completion(NO, error);
    } else {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(success, error);
            });
        }];
    }
}

+ (void)copyContentToPasteboard:(NSString *)content {
    [UIPasteboard generalPasteboard].string = content;
}

+ (NSString *)base64Encode:(NSString *)input {
    return  [[input dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
}

+ (NSString *)base64Decode:(NSString *)input {
    return [[NSString alloc ] initWithData:[[NSData alloc] initWithBase64EncodedString:input options:0] encoding:NSUTF8StringEncoding];
}

+ (NSString *)urlEncode:(NSString *)input {
    return [input stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
}

+ (NSMutableDictionary *)parseUrl:(NSURL *)url {
    NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
    NSArray *urlComponents = [[url query] componentsSeparatedByString:@"&"];
    for (NSString *keyValuePair in urlComponents) {
        NSRange range = [keyValuePair rangeOfString:@"="];
        [mDic setObject:range.length > 0 ? [keyValuePair substringFromIndex:range.location + 1] : @"" forKey:range.length ? [keyValuePair substringToIndex:range.location] : keyValuePair];
    }
    return mDic;
}

@end
