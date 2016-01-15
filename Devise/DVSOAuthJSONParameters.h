//
//  DVSOAuthJSONParameters.h
//  Devise
//
//  Created by Pawel Bialecki on 04.03.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DVSOAuthProvider) {
    DVSOAuthProviderFacebook,
    DVSOAuthProviderGoogle
};

@interface DVSOAuthJSONParameters : NSObject

/**
 *  Builds authorization parameters
 *  @param provider     Type of provider for which you would like to get authorization parameters
 *  @param oAuthToken   The authorization token
 *  @param userID       The user ID to use
 */
+ (NSDictionary *)dictionaryForParametersWithProvider:(DVSOAuthProvider)provider oAuthToken:(NSString *)oAuthToken userID:(NSString *)userID userEmail:(NSString *)email userFirstName:(NSString *)firstName userLastName:(NSString *)lastName;

@end
