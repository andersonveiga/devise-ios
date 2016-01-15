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

@interface DVSFacebookAuthenticator ()

@property (nonatomic, strong) NSString *appID;

@end

@implementation DVSFacebookAuthenticator

- (instancetype)initWithAppID:(NSString *)appID {
    self = [super init];
    if (self) {
        _appID = appID;
    }
    return self;
}

- (void)authenticateWithSuccess:(DVSDictionaryBlock)success failure:(DVSErrorBlock)failure {
    
    NSAssert(self.appID, @"AppID cannot be nil. Remember to initialize authenticator with initWithAppID: method");
    
    DVSFacebookAccountStore *store = [[DVSFacebookAccountStore alloc] initWithAppID:self.appID permissions:@[@"email"]];
    [store requestAccessWithCompletion:^(ACAccount *account, NSError *error) {
        if (account) {
            [self makeRequestWithAccount:account success:success failure:failure];
        } else {
            if (failure != NULL) failure(error);
        }
    }];
}

#pragma mark - Private methods

- (void)makeRequestWithAccount:(ACAccount *)account success:(DVSDictionaryBlock)success failure:(DVSErrorBlock)failure {
    
    NSDictionary *params = @{@"fields":@"email,first_name,last_name"};
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                            requestMethod:SLRequestMethodGET
                                                      URL:[NSURL URLWithString:@"https://graph.facebook.com/me"]
                                               parameters:params];
    request.account = account;
    
    [request performRequestWithHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            if (failure != NULL) failure(error);
        } else {
            [self checkResponse:response data:data token:account.credential.oauthToken success:success failure:failure];
        }
    }];
}

- (void)checkResponse:(NSURLResponse *)response data:(NSData *)data token:(NSString *)token success:(DVSDictionaryBlock)success failure:(DVSErrorBlock)failure  {
    
    if ([self isResponseValid:response]) {
        NSError *deserializationError;
        id userData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&deserializationError];
        
        if (deserializationError) {
            if (failure != NULL) failure(deserializationError);
        } else {
            NSDictionary *parameters = [self parametersFromUserData:userData token:token];
            if (success != NULL) success(parameters);
        }
    } else {
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:@{NSLocalizedFailureReasonErrorKey: @"Facebook response is not valid!"}];
        if (failure != NULL) failure(error);
    }
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

- (BOOL)isResponseValid:(NSURLResponse *)response {
    return ((NSHTTPURLResponse *)response).statusCode == 200;
}

@end
