//
//  DVSFacebookAuthenticator.h
//  Devise
//
//  Created by Pawel Bialecki on 09.03.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DVSTypedefs.h"

@interface DVSFacebookAuthenticator : NSObject

/**
 *  Initializes DVSFacebookAuthenticator for authentication with facebook as 3rd party service.
 *
 *  @param appID Application's facebook app ID
 *
 *  @return Instance of DVSFacebookAuthenticator.
 */
- (instancetype)initWithAppID:(NSString *)appID NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

/**
 *  Authenticate user with app ID given in init method.
 *
 *  @param success Block invoked when authentication succeed. Provides formatted parameter dictionary according to devise-ios convention.
 *  @param failure Block invoked when authentication failed. Reurns error.
 */
- (void)authenticateWithSuccess:(DVSDictionaryBlock)success failure:(DVSErrorBlock)failure;

@end
