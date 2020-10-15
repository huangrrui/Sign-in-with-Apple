//
//  AppDelegate.m
//  SignInWithApple
//
//  Created by 黄瑞 on 2020/10/14.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[[ASAuthorizationAppleIDProvider alloc] init] getCredentialStateForUserID:[self getUserId] completion:^(ASAuthorizationAppleIDProviderCredentialState credentialState, NSError * _Nullable error) {
        // 查询当前账号是否在钥匙串中有记录了，不需要用户重复登录
        switch (credentialState) {
            case ASAuthorizationAppleIDProviderCredentialRevoked:
                NSLog(@"ASAuthorizationAppleIDProviderCredentialRevoked");
                break;
            case ASAuthorizationAppleIDProviderCredentialAuthorized:
                NSLog(@"ASAuthorizationAppleIDProviderCredentialAuthorized");
                break;
            case ASAuthorizationAppleIDProviderCredentialNotFound:
                NSLog(@"ASAuthorizationAppleIDProviderCredentialNotFound");
                break;
            case ASAuthorizationAppleIDProviderCredentialTransferred:
                NSLog(@"ASAuthorizationAppleIDProviderCredentialTransferred");
                break;
            default:
                break;
        }
    }];
    
    return YES;
}

- (NSString *)getUserId {
    // 单用户登录，直接写死账号，只需要查到 userId 即可
    NSDictionary *query = @{
        (NSString *)kSecClass: (NSString *)kSecClassGenericPassword,
        (NSString *)kSecMatchLimit: (NSString *)kSecMatchLimitOne, // 只返回一个记录
        (NSString *)kSecAttrAccount: @"appAccount", // 账号写死
        (NSString *)kSecReturnData: @(YES), // 需要返回 Item 的 Data，数据保存在这里
        // 返回对象的类型不同
        // 值为 YES 时，attributes 和 data 放在同一个 CFDictionaryRef 中返回
        // 值为 NO 时，单独返回 data，放在 CFDataRef 中返回
        (NSString *)kSecReturnAttributes: @(YES),
    };
    CFTypeRef result;
    OSStatus res = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    if (res == errSecSuccess) {
        NSDictionary *resDic = (__bridge_transfer NSDictionary *)result;
        NSData * data = resDic[(NSString *)kSecValueData];
        NSString *user = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return user;
    } else {
        return nil;
    }
}

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
