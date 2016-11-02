//
//  DVSGooglePlusAuthenticator.m
//  Devise
//
//  Created by Pawel Bialecki on 09.03.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "DVSGooglePlusAuthenticator.h"
#import "DVSOAuthJSONParameters.h"


#import <Google/SignIn.h>

@interface DVSGooglePlusAuthenticator () <GIDSignInDelegate>

@property (copy, nonatomic) DVSErrorBlock failure;
@property (copy, nonatomic) DVSDictionaryBlock success;

@end

@implementation DVSGooglePlusAuthenticator

- (instancetype)init{
    self = [super init];
    if (self) {

        NSError* configureError;
        [[GGLContext sharedInstance] configureWithError: &configureError];
        NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
        
        GIDSignIn *signIn = [GIDSignIn sharedInstance];
        signIn.shouldFetchBasicProfile = YES;

    }
    return self;
}

- (void)dealloc {
    [GIDSignIn sharedInstance].delegate = nil;
}

#pragma mark - Public methods

- (void)authenticateWithSuccess:(DVSDictionaryBlock)success failure:(DVSErrorBlock)failure {
    self.success = success;
    self.failure = failure;
    [self authenticate];
}

- (BOOL)handleURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation  {
    
//    NSDictionary *options = @{UIApplicationOpenURLOptionsSourceApplicationKey: sourceApplication,
//                              UIApplicationOpenURLOptionsAnnotationKey: annotation};
    
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:sourceApplication
                                      annotation:annotation];
}

- (void)signOut{
    [GIDSignIn sharedInstance].delegate = self;
    [[GIDSignIn sharedInstance] signOut];
}

//- (BOOL)application:(UIApplication *)app
//            openURL:(NSURL *)url
//            options:(NSDictionary *)options {
//    return [[GIDSignIn sharedInstance] handleURL:url
//                               sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
//                                      annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
//}
//
//- (BOOL)application:(UIApplication *)application
//            openURL:(NSURL *)url
//  sourceApplication:(NSString *)sourceApplication
//         annotation:(id)annotation {
//    NSDictionary *options = @{UIApplicationOpenURLOptionsSourceApplicationKey: sourceApplication,
//                              UIApplicationOpenURLOptionsAnnotationKey: annotation};
//    return [self application:application
//                     openURL:url
//                     options:options];
//}

#pragma mark - Google+ SDK helpers

- (void)authenticate {
    [GIDSignIn sharedInstance].delegate = self;
    [[GIDSignIn sharedInstance] signIn];
}


#pragma mark - GIDSignInDelegate

- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {

    if (error) {
        if (self.failure != NULL) self.failure(error);
    } else {
        NSDictionary *parameters = [DVSOAuthJSONParameters dictionaryForParametersWithProvider:DVSOAuthProviderGoogle oAuthToken:user.authentication.accessToken userID:user.userID userEmail:user.profile.email userFirstName:user.profile.name userLastName:@""];
        
        if (self.success != NULL) self.success(parameters);
    }
}

- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    if (self.failure != NULL) self.failure(error);
}


@end
