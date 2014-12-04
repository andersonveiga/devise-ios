//
//  DVSAPIManager.m
//
//  Copyright (c) 2014 Netguru.co. All rights reserved.
//

#import "DVSAPIManager.h"
#import "DVSHTTPReqeustOperationManager.h"
#import "DVSConfiguration.h"
#import "DVSUser+Querying.h"
#import "DVSUser+Memorize.h"
#import "DVSMacros.h"
#import "NSError+Devise.h"

@implementation DVSAPIManager

#pragma mark - Public Methods

+ (void)registerUser:(DVSUser *)user withSuccess:(DVSVoidBlock)success failure:(DVSErrorBlock)failure {
    
    DVSDLog(@"\nRegistration:\n\nGET: %@\n\nPOST: %@", [user registerQuery], [user registerPOST]);
    
    DVSRequestType requestType = [user requestTypeForSelector:@selector(requestTypeForUserRegistration:)];
    NSString *path = [[DVSConfiguration sharedConfiguration] pathForRoute:DVSRouteRegister];
    
    if (requestType == DVSRequestPOST) {
        
        [DVSNetworkManager requestWithPOST:[user registerPOST] path:path success:^(NSDictionary *response) {
            [user dvs_saveSensitiveData:response] ? success () : failure([NSError dvs_errorWithErrorResponse:response]);
        } failure:^(NSError *error) {
            failure(error);
        }];
    } else {
        
        [DVSNetworkManager requestWithGET:[user registerQuery] path:path success:^(NSDictionary *response) {
            [user dvs_saveSensitiveData:response] ? success () : failure([NSError dvs_errorWithErrorResponse:response]);
        } failure:^(NSError *error) {
            failure(error);
        }];
    }
}

+ (void)loginUser:(DVSUser *)user withSuccess:(DVSVoidBlock)success failure:(DVSErrorBlock)failure {
    
    DVSDLog(@"\nLogin:\n\nGET: %@\n\nPOST: %@", [user loginQuery], [user loginPOST]);
    
    DVSRequestType requestType = [user requestTypeForSelector:@selector(requestTypeForUserLogin:)];
    NSString *path = [[DVSConfiguration sharedConfiguration] pathForRoute:DVSRouteLogin];
    
    if (requestType == DVSRequestPOST) {
        
        [DVSNetworkManager requestWithPOST:[user loginPOST] path:path success:^(NSDictionary *response) {
            [user dvs_saveSensitiveData:response] ? success () : failure([NSError dvs_errorWithErrorResponse:response]);
        } failure:^(NSError *error) {
            failure(error);
        }];
    } else {
        
        [DVSNetworkManager requestWithGET:[user loginQuery] path:path success:^(NSDictionary *response) {
            [user dvs_saveSensitiveData:response] ? success () : failure([NSError dvs_errorWithErrorResponse:response]);
        } failure:^(NSError *error) {
            failure(error);
        }];
    }
}

+ (void)remindPasswordForUser:(DVSUser *)user withSuccess:(DVSVoidBlock)success failure:(DVSErrorBlock)failure {
    
    DVSDLog(@"\nRemind Password:\n\nGET: %@\n\nPOST: %@", [user forgotPasswordQuery], [user forgotPasswordPOST]);
    
    NSString *path = [[DVSConfiguration sharedConfiguration] pathForRoute:DVSRouteForgotPassword];
    
    [DVSNetworkManager requestWithPOST:[user forgotPasswordPOST] path:path success:^(NSDictionary *dictionary) {
        success();
    } failure:^(NSError *error) {
        failure(error);
    }];
}

@end
