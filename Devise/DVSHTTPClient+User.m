//
//  DVSHTTPClient+User.m
//  
//  Copyright (c) 2014 Netguru Sp. z o.o. All rights reserved.
//

#import "DVSHTTPClient+User.h"
#import <objc/runtime.h>
#import "DVSUser.h"
#import "DVSUser+Persistence.h"
#import "DVSUserJSONSerializer+Serialize.h"
#import "NSDictionary+Devise+Private.h"
#import "NSObject+Devise+Private.h"

NSString * const DVSHTTPClientDefaultRegisterPath = @"";
NSString * const DVSHTTPClientDefaultLogInPath = @"sign_in";
NSString * const DVSHTTPClientDefaultUpdatePath = @"";
NSString * const DVSHTTPClientDefaultDeletePath = @"";
NSString * const DVSHTTPClientDefaultChangePasswordPath = @"password";
NSString * const DVSHTTPClientDefaultRemindPasswordPath = @"password";
NSString * const DVSHTTPClientDefaultFacebookSigningPath = @"auth/facebook";
NSString * const DVSHTTPClientDefaultGoogleSigningPath = @"auth/google";

@interface DVSUser ()

@property (strong, nonatomic, readwrite) NSString *identifier;
@property (strong, nonatomic, readwrite) NSString *sessionToken;

@end

#pragma mark -

@implementation DVSHTTPClient (User)

#pragma mark - Standard methods

- (void)registerUser:(DVSUser *)user success:(DVSUserBlock)success failure:(DVSErrorBlock)failure {
    
    NSString *path = DVSHTTPClientDefaultRegisterPath;
    NSDictionary *parameters = [self.userSerializer registerJSONDictionaryForUser:user];
    [self makePostRequestWithPath:path user:user parameters:parameters success:success failure:failure];
}

- (void)logInUser:(DVSUser *)user success:(DVSUserBlock)success failure:(DVSErrorBlock)failure {
    
    NSString *path = DVSHTTPClientDefaultLogInPath;
    NSDictionary *parameters = [self.userSerializer loginJSONDictionaryForUser:user];
    [self makePostRequestWithPath:path user:user parameters:parameters success:success failure:failure];
}

- (void)signInUsingFacebookUser:(DVSUser *)user parameters:(NSDictionary *)parameters success:(DVSUserBlock)success failure:(DVSErrorBlock)failure {
    
    NSString *path = DVSHTTPClientDefaultFacebookSigningPath;
    [self makePostRequestWithPath:path user:user parameters:parameters success:success failure:failure];
}

- (void)signInUsingGoogleUser:(DVSUser *)user parameters:(NSDictionary *)parameters success:(DVSUserBlock)success failure:(DVSErrorBlock)failure {
    
    NSString *path = DVSHTTPClientDefaultGoogleSigningPath;
    [self makePostRequestWithPath:path user:user parameters:parameters success:success failure:failure];
}

- (void)updateUser:(DVSUser *)user success:(DVSUserBlock)success failure:(DVSErrorBlock)failure {
    
    NSString *path = DVSHTTPClientDefaultUpdatePath;
    NSDictionary *parameters = [self.userSerializer updateJSONDictionaryForUser:user];
    [self makePutRequestWithPath:path user:user parameters:parameters success:success failure:failure];
}

- (void)changePasswordOfUser:(DVSUser *)user success:(DVSUserBlock)success failure:(DVSErrorBlock)failure {
    
    NSString *path = DVSHTTPClientDefaultChangePasswordPath;
    NSDictionary *parameters = [self.userSerializer changePasswordJSONDictionaryForUser:user];
    [self makePutRequestWithPath:path user:user parameters:parameters success:success failure:failure];
}

- (void)deleteUser:(DVSUser *)user success:(DVSVoidBlock)success failure:(DVSErrorBlock)failure {
    
    NSString *path = DVSHTTPClientDefaultDeletePath;
    [self setupHTTPHeaderWithAuthorizationToken:user.sessionToken];
    
    [self DELETE:path parameters:nil completion:^(__unused id responseObject, NSError *error) {
        if (error != nil) {
            if (failure != NULL) failure(error);
        } else {
            if (success != NULL) success();
        }
    }];
}

- (void)remindPasswordToUser:(DVSUser *)user success:(DVSVoidBlock)success failure:(DVSErrorBlock)failure {
   
    NSString *path = DVSHTTPClientDefaultRemindPasswordPath;
    NSDictionary *parameters = [self.userSerializer remindPasswordJSONDictionaryForUser:user];
    
    [self POST:path parameters:parameters completion:^(__unused id responseObject, NSError *error) {
        if (error != nil) {
            if (failure != NULL) failure(error);
        } else {
            if (success != NULL) success();
        }
    }];
}

#pragma mark - Authorization

- (void)setupHTTPHeaderWithAuthorizationToken:(NSString *)token {
    [self setValue:token forHTTPHeaderField:@"X-User-Token"];
    [self setValue:[self.delegate emailForAuthorizationHeaderInHTTPClient:self] forHTTPHeaderField:@"X-User-Email"];
}

#pragma mark - Accessors

- (DVSUserJSONSerializer *)userSerializer {
    DVSUserJSONSerializer *serializer = (DVSUserJSONSerializer *)objc_getAssociatedObject(self, @selector(userSerializer));
    if (!serializer) {
        serializer = [DVSUserJSONSerializer new];
        objc_setAssociatedObject(self, @selector(userSerializer), serializer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return serializer;
}

#pragma mark - Private methods

- (void)makePostRequestWithPath:(NSString *)path user:(DVSUser *)user parameters:(NSDictionary *)parameters success:(DVSUserBlock)success failure:(DVSErrorBlock)failure {
   
    [self POST:path parameters:parameters completion:^(id responseObject, NSError *error) {
        if (error != nil) {
            if (failure != NULL) failure(error);
        } else {
            
            if ([self.userSerializer.JSONKeyPathForRemoteRoot length] > 0) {
                [self fillUser:user withJSONRepresentation:responseObject[self.userSerializer.JSONKeyPathForRemoteRoot]];
            } else {
                [self fillUser:user withJSONRepresentation:responseObject];
            }
            if (success != NULL) success(user);
        }
    }];
}

- (void)makePutRequestWithPath:(NSString *)path user:(DVSUser *)user parameters:(NSDictionary *)parameters success:(DVSUserBlock)success failure:(DVSErrorBlock)failure {
    
    [self setupHTTPHeaderWithAuthorizationToken:user.sessionToken];
   
    [self PUT:path parameters:parameters completion:^(id responseObject, NSError *error) {
        if (error != nil) {
            if (failure != NULL) failure(error);
        } else {
            if ([self.userSerializer.JSONKeyPathForRemoteRoot length] > 0) {
                [self fillUser:user withJSONRepresentation:responseObject[self.userSerializer.JSONKeyPathForRemoteRoot]];
            } else {
                [self fillUser:user withJSONRepresentation:responseObject];
            }
            if (success != NULL) success(user);
        }
    }];
}

- (void)fillUser:(DVSUser *)user withJSONRepresentation:(NSDictionary *)json {
    for (NSString *key in [user dvs_properties]) {
        if (json[key] != nil) {
            [user setValue:json[key] forKey:key];
        }
    }

    user.identifier = [json dvs_stringValueForKey:@"id"];
    user.email = [json dvs_stringValueForKey:@"email"];
    user.sessionToken = [json dvs_stringValueForKey:self.userSerializer.JSONKeyPathForAuthenticationToken];
}

@end
