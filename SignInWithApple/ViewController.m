//
//  ViewController.m
//  SignInWithApple
//
//  Created by 黄瑞 on 2020/10/14.
//

#import "ViewController.h"
#import <AuthenticationServices/AuthenticationServices.h>

@interface ViewController ()

<
ASAuthorizationControllerDelegate,
ASAuthorizationControllerPresentationContextProviding
>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BOOL isCustom = YES;
    
    // 登录按钮可以自定义样式，也可以用系统的样式
    if (isCustom) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setBackgroundColor:[UIColor blueColor]];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitle:@"Login" forState:UIControlStateNormal];
        button.frame = CGRectMake(0, 0, 40 * 1.73, 40);
        button.center = self.view.center;
        [button addTarget:self action:@selector(onLoginClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    } else {
        ASAuthorizationAppleIDButton *button = [ASAuthorizationAppleIDButton
                                                buttonWithType:ASAuthorizationAppleIDButtonTypeSignUp
                                                style:ASAuthorizationAppleIDButtonStyleBlack];
        button.center = self.view.center;
        [button addTarget:self action:@selector(onLoginClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
}

- (void)onLoginClick {
    ASAuthorizationAppleIDProvider *provider = [[ASAuthorizationAppleIDProvider alloc] init];
    ASAuthorizationAppleIDRequest *request = [provider createRequest];
    
    // 获取 用户名 和 Email（同一 BundleId 首次使用 Sign in with Apple 才有对应的值返回）
    request.requestedScopes = @[
        ASAuthorizationScopeFullName,
        ASAuthorizationScopeEmail,
    ];
    
    ASAuthorizationController *controller = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[request]];
    controller.delegate = self;
    controller.presentationContextProvider = self;
    [controller performRequests];
}

- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization {
    // 鉴权成功
    // 将登录凭证保存到钥匙串中
    if ([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]]) {
        // 如果是 AppleID 凭证，保存
        ASAuthorizationAppleIDCredential *credential = (ASAuthorizationAppleIDCredential *)authorization.credential;
        
        // email 和 fullName，仅在同一 BundleId 第一次使用 Sign in with Apple 时才有值
        NSLog(@"user = %@", credential.user);
        NSLog(@"state = %@", credential.state);
        NSLog(@"authorizedScopes = %@", credential.authorizedScopes);
        NSLog(@"authorizationCode = %@", credential.authorizationCode);
        NSLog(@"identityToken = %@", credential.identityToken);
        NSLog(@"email = %@", credential.email);
        NSLog(@"namePrefix = %@", credential.fullName.namePrefix);
        NSLog(@"givenName = %@", credential.fullName.givenName);
        NSLog(@"middleName = %@", credential.fullName.middleName);
        NSLog(@"familyName = %@", credential.fullName.familyName);
        NSLog(@"nameSuffix = %@", credential.fullName.nameSuffix);
        NSLog(@"nickname = %@", credential.fullName.nickname);
        NSLog(@"%ld", (long)credential.realUserStatus);

        NSData *userData = [credential.user dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *attributes = @{
            (NSString *)kSecClass: (NSString *)kSecClassGenericPassword,
            // 单用户登录，账号可以写死
            (NSString *)kSecAttrAccount: @"appAccount",
            // 当 kSecClass = kSecClassGenericPassword 时，kSecValueData 里的内容会加密，更安全
            (NSString *)kSecValueData: userData,
        };
        CFTypeRef result;
        OSStatus res = SecItemAdd((__bridge CFDictionaryRef)attributes, (CFTypeRef *)&result);
        if (res == errSecSuccess) {
            NSLog(@"success");
        }
    }
}

- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error {
    // 鉴权失败
}

- (ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller {
    // 在哪个 Window 展示登录框
    return UIApplication.sharedApplication.windows.firstObject;
}

@end
