//
//  DVSUserManager.m
//  Devise
//
//  Created by Wojciech Trzasko on 11.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "DVSUserManager.h"
#import <ngrvalidator/NGRValidator.h>
#import "DVSConfiguration.h"
#import "DVSHTTPClient+User.h"
#import "DVSUserPersistenceStore.h"
#import "DVSGooglePlusAuthenticator.h"
#import "DVSFacebookAuthenticator.h"

@interface DVSUserManager () <DVSHTTPClientDelegate>

//@property (strong, nonatomic, readwrite) DVSUser *user;
@property (strong, nonatomic) DVSUserPersistenceStore *persistenceStore;
@property (strong, nonatomic) DVSGooglePlusAuthenticator *googlePlusAuthenticator;
@property (strong, nonatomic) DVSFacebookAuthenticator *facebookAuthenticator;

@end

@implementation DVSUserManager

#pragma mark - Object lifecycle

- (instancetype)initWithUser:(DVSUser *)user {
    return [self initWithUser:user configuration:[DVSConfiguration sharedConfiguration]];
}

- (instancetype)initWithUser:(DVSUser *)user configuration:(DVSConfiguration *)configuration {
    self = [super init];
    if (self) {
        _user = user;
        _httpClient = [[DVSHTTPClient alloc] initWithConfiguration:configuration];
        _httpClient.delegate = self;
        _persistenceStore = [[DVSUserPersistenceStore alloc] initWithConfiguration:configuration];
    }
    return self;
}

+ (instancetype)defaultManager {
    static DVSUserManager *sharedMyManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[DVSUserManager alloc] initWithUser:nil configuration:[DVSConfiguration sharedConfiguration]];
        sharedMyManager.user = sharedMyManager.persistenceStore.localUser;
    });
    return sharedMyManager;
}

- (DVSUser *)persistentUser {
    return self.persistenceStore.persistentUser;
}

#pragma mark - DVSHTTPClientDelegate

- (NSString *)emailForAuthorizationHeaderInHTTPClient:(DVSHTTPClient *)client {
    return [self persistentUser].email;
}

#pragma mark - Logging in

- (void)loginWithSuccess:(DVSVoidBlock)success failure:(DVSErrorBlock)failure {
    NSArray *rules = @[[self validationRulesForPassword],
                       [self validationRulesForEmail]];
    
    [self validateUsingRules:rules forAction:DVSActionLogin success:^{
        [self.httpClient logInUser:self.user success:^(DVSUser *user) {
            
            self.persistenceStore.localUser = user;
            if (success != NULL) success();
        } failure:failure];
    } failure:failure];
}

#pragma mark - Remind password

- (void)remindPasswordWithSuccess:(DVSVoidBlock)success failure:(DVSErrorBlock)failure {
    NSArray *rules = @[[self validationRulesForEmail]];
    
    [self validateUsingRules:rules forAction:DVSActionRemindPassword success:^{
        [self.httpClient remindPasswordToUser:self.user success:success failure:failure];
    } failure:failure];
}

#pragma mark - Registration

- (void)registerWithSuccess:(DVSVoidBlock)success failure:(DVSErrorBlock)failure {
    NSArray *rules = @[[self validationRulesForPassword],
                       [self validationRulesForEmail]];
    
    [self validateUsingRules:rules forAction:DVSActionRegistration success:^{
        [self.httpClient registerUser:self.user success:^(DVSUser *user) {
            if (success != NULL) success();
        } failure:failure];
    } failure:failure];
}

#pragma mark - Signing via Facebook

- (void)signInUsingFacebookWithSuccess:(DVSVoidBlock)success failure:(DVSErrorBlock)failure {
    
    [self.facebookAuthenticator authenticateWithSuccess:^(NSDictionary *dictionary) {
        [self.httpClient signInUsingFacebookUser:self.user parameters:dictionary success:^(DVSUser *user) {
            self.persistenceStore.localUser = user;
            if (success != NULL) success();
        } failure:failure];
    } failure:failure];
}

#pragma mark - Signing via Google

- (void)signInUsingGoogleWithSuccess:(DVSVoidBlock)success failure:(DVSErrorBlock)failure {
    
    [self.googlePlusAuthenticator authenticateWithSuccess:^(NSDictionary *dictionary) {
        [self.httpClient signInUsingGoogleUser:self.user parameters:dictionary success:^(DVSUser *user) {
            self.persistenceStore.localUser = user;
            if (success != NULL) success();
        } failure:failure];
    } failure:failure];
}

#pragma mark - Change password

- (void)changePasswordWithSuccess:(DVSVoidBlock)success failure:(DVSErrorBlock)failure {
    NSArray *rules = @[[self validationRulesForPassword]];
    [self validateUsingRules:rules forAction:DVSActionChangePassword success:^{
        [self.httpClient changePasswordOfUser:self.user success:^(DVSUser *user) {
            self.persistenceStore.localUser = user;
            if (success != NULL) success();
        } failure:failure];
    } failure:failure];
}

#pragma mark - Update methods

- (void)updateWithSuccess:(DVSVoidBlock)success failure:(DVSErrorBlock)failure {
    NSArray *rules = @[[self validationRulesForEmail]];
    [self validateUsingRules:rules forAction:DVSActionUpdate success:^{
        [self.httpClient updateUser:self.user success:^(DVSUser *user) {
            self.persistenceStore.localUser = user;
            if (success != NULL) success();
        } failure:failure];
    } failure:failure];
}

#pragma mark - Handle callback
- (BOOL)handleURL:(NSURL *)url application:(UIApplication *)application sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL googleHandled = [self.googlePlusAuthenticator handleURL:url sourceApplication:sourceApplication annotation:annotation];
    BOOL fbHandled = [self.facebookAuthenticator handleURL:url application:application sourceApplication:sourceApplication annotation:annotation];
    return (googleHandled || fbHandled);
}

#pragma mark - Delete account

- (void)deleteAccountWithSuccess:(DVSVoidBlock)success failure:(DVSErrorBlock)failure {
    [self.httpClient deleteUser:self.user success:^{
        self.persistenceStore.localUser = nil;
        if (success != NULL) success();
    } failure:failure];
}

#pragma mark - Logout method

- (void)logout {
    [self.facebookAuthenticator logOut];
    [self.googlePlusAuthenticator signOut];
    self.persistenceStore.localUser = nil;
}
- (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    [self.facebookAuthenticator application:application didFinishLaunchingWithOptions:launchOptions];
}

#pragma mark - Validation

- (void)validateUsingRules:(NSArray *)rules forAction:(DVSActionType)action success:(DVSVoidBlock)success failure:(DVSErrorBlock)failure {
    
    NSError *error;
    BOOL validated = [NGRValidator validateModel:self.user error:&error delegate:nil rules:^NSArray *{
        
        NSMutableArray *currentValidationRules = [NSMutableArray arrayWithArray:rules];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(userManager:didPrepareValidationRules:forAction:)]) {
            [self.delegate userManager:self didPrepareValidationRules:currentValidationRules forAction:action];
        }

        return [currentValidationRules copy];
    }];
    if (validated) {
        if (success != NULL) success();
    } else if (failure != NULL) {
        failure(error);
    }
}

- (NSArray *)mergeDefaultRules:(NSArray *)defaultRules withCustomRules:(NSArray *)customRules {
    NSMutableArray *array = [NSMutableArray arrayWithArray:defaultRules];
    [array addObjectsFromArray:customRules];
    return [array copy];
}

#pragma mark - Validation Rules

- (NGRPropertyValidator *)validationRulesForPassword {
    return NGRValidate(@"password").required();
}

- (NGRPropertyValidator *)validationRulesForEmail {
    return NGRValidate(@"email").required().syntax(NGRSyntaxEmail);
}

#pragma mark - Accessors

- (DVSUserJSONSerializer *)serializer {
    return self.httpClient.userSerializer;
}

- (DVSGooglePlusAuthenticator *)googlePlusAuthenticator {
    if (_googlePlusAuthenticator) return _googlePlusAuthenticator;
    return (_googlePlusAuthenticator = [[DVSGooglePlusAuthenticator alloc] init]);
}

- (DVSFacebookAuthenticator *)facebookAuthenticator {
    if(_facebookAuthenticator) return _facebookAuthenticator;
    return (_facebookAuthenticator = [[DVSFacebookAuthenticator alloc] init]);
}

@end
