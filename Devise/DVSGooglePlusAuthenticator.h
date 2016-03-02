//
//  DVSGooglePlusAuthenticator.h
//  Devise
//
//  Created by Pawel Bialecki on 09.03.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DVSTypedefs.h"

/**
 *  DVSGooglePlusAuthenticator uses GPPSignIn under the hood and it needs Google+ SDK to work.
 *  If you want to customize GPPSignIn even more, please use [GPPSignIn sharedInstance].
 */
@interface DVSGooglePlusAuthenticator : NSObject

/**
 *  Authenticate user with Google client ID given in init method. Shared instance of GPSignIn object will be used.
 *
 *  @param clientID Application's client ID.
 *  @param success Block invoked when authentication succeed. Provides formatted parameter dictionary according to devise-ios convention.
 *  @param failure Block invoked when authentication failed. Reurns error.
 */
- (void)authenticateWithSuccess:(DVSDictionaryBlock)success failure:(DVSErrorBlock)failure;

//- (void)signoutWithSuccess:(DVSDictionaryBlock)success failure:(DVSErrorBlock)failure;
- (void)signOut;

/**
 *  Passes arguments to GPPSignIn handleURL:sourceApplication:annotation: method
 */
- (BOOL)handleURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

@end
