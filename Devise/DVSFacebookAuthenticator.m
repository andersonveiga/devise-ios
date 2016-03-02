//
//  DVSFacebookAuthenticator.m
//  Devise
//
//  Created by Pawel Bialecki on 09.03.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import Accounts;
@import Social;

#import "DVSFacebookAuthenticator.h"
#import "DVSOAuthJSONParameters.h"
#import "DVSFacebookAccountStore.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface DVSFacebookAuthenticator ()

@property (nonatomic, strong) FBSDKLoginManager *loginManager;

@end

@implementation DVSFacebookAuthenticator

- (instancetype)init {
    self = [super init];
    return self;
}

- (void)authenticateWithSuccess:(DVSDictionaryBlock)success failure:(DVSErrorBlock)failure {
    
    __weak typeof(self) weakSelf = self;
    if ([FBSDKAccessToken currentAccessToken]) {
        [weakSelf requestData:success failure:failure];
    } else {
        [self.loginManager logInWithReadPermissions: @[@"public_profile"]
                     fromViewController:nil handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                         if (error) {
                             failure(error);
                         } else if (result.isCancelled) {
                         } else {
                             
                             [weakSelf requestData:success failure:failure];
                         }
                     }];
    }
}

- (void)requestData:(DVSDictionaryBlock)success failure:(DVSErrorBlock)failure{
    NSDictionary *parameters = @{@"fields":@"id,first_name,last_name,email"};
    
    __weak typeof(self) weakSelf = self;

    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
             NSDictionary *parameters = [weakSelf parametersFromUserData:result token:token.tokenString];
             success(parameters);
         } else {
             failure(error);
         }
     }];
}

- (void)logOut{
    [self.loginManager logOut];
    self.loginManager = nil;
}

- (BOOL)handleURL:(NSURL *)url application:(UIApplication *)application sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation
            ];
}

- (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
}

#pragma mark - Helpers

- (NSDictionary *)parametersFromUserData:(id)userData token:(NSString *)token {
    return [DVSOAuthJSONParameters dictionaryForParametersWithProvider:DVSOAuthProviderFacebook
                                                            oAuthToken:token
                                                                userID:userData[@"id"]
                                                             userEmail:userData[@"email"]
                                                         userFirstName:userData[@"first_name"]
                                                          userLastName:userData[@"last_name"]];
}

- (FBSDKLoginManager *)loginManager{
    if(_loginManager) return _loginManager;
    return (_loginManager = [[FBSDKLoginManager alloc] init]);
}

@end
