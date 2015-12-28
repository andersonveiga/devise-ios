//
//  DVSUserManager.h
//  Devise
//
//  Created by Wojciech Trzasko on 11.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DVSUser.h"
#import "DVSUserJSONSerializer.h"
#import "DVSHTTPClient.h"

@protocol DVSUserManagerDelegate;

@interface DVSUserManager : NSObject

/**
 *  The model of user class associated with DVSUserManager.
 *  DefaultManager uses user model from keychain store.
 */
@property (strong, nonatomic, readonly) DVSUser *user;

/**
 *  JSON serializer used in forming request.
 */
@property (strong, nonatomic, readonly) DVSUserJSONSerializer *serializer;

/**
 *  The manager's delegate object.
 */
@property (weak, nonatomic) id<DVSUserManagerDelegate> delegate;

/**
 *  The HTTP client used by the model for networking purposes.
 */
@property (strong, nonatomic) DVSHTTPClient *httpClient;

/**
 *  Initialized DVSUserManager with locally saved user object (if any) and default configuration.
 */
+ (instancetype)defaultManager;

/**
 *  Initializes manager class. Use it to provide own user (other than stored locally).
 *
 *  @param user The model of user.
 *
 *  @return Instance of receiver.
 */
- (instancetype)initWithUser:(DVSUser *)user;

/**
 *  Default initializer for manager class. Use it to provide own user (other than stored locally) and configuration (other than sharedConfiguration).
 *
 *  @param user          The instance of user model class. If sublass of DVSUser class was given in any
 *  @param configuration The configuration used to initialize DVSHTTPClient.
 *
 *  @return Instance of receiver.
 */
- (instancetype)initWithUser:(DVSUser *)user configuration:(DVSConfiguration *)configuration NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

/**
 *  Returns fresh copy of user model taken from keychain store. If model doesn't exist, returns nil.
 *  Notice that persistentUser can be different from user if any changes has been made.
 */
- (DVSUser *)persistentUser;

/**
 *  Login user asynchronously. When succeed user will be stored locally so
 *  calls to currentUser will return the latest logged in user.
 */
- (void)loginWithSuccess:(DVSVoidBlock)success failure:(DVSErrorBlock)failure;

/**
 *  Reminds user password asynchronously.
 */
- (void)remindPasswordWithSuccess:(DVSVoidBlock)success failure:(DVSErrorBlock)failure;

/**
 *  Registers user asynchronously.
 */
- (void)registerWithSuccess:(DVSVoidBlock)success failure:(DVSErrorBlock)failure;

/**
 *  Signs in user asynchronously via Facebook.
 */
- (void)signInUsingFacebookWithSuccess:(DVSVoidBlock)success failure:(DVSErrorBlock)failure;

/**
 *  Signs in user asynchronously via Google.
 */
- (void)signInUsingGoogleWithSuccess:(DVSVoidBlock)success failure:(DVSErrorBlock)failure;

/**
 *  Changes user password asynchronously.
 */
- (void)changePasswordWithSuccess:(DVSVoidBlock)success failure:(DVSErrorBlock)failure;

/**
 *  Update user info asynchronously.
 */
- (void)updateWithSuccess:(DVSVoidBlock)success failure:(DVSErrorBlock)failure;

/**
 *  Deletes account associated with user asynchronously. When succeed removes also user related data from keychain.
 */
- (void)deleteAccountWithSuccess:(DVSVoidBlock)success failure:(DVSErrorBlock)failure;

/**
 *  Handles authorization via GooglePlus callback.
 */
- (BOOL)handleURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

/**
 *  Deletes locally stored user.
 */
- (void)logout;

@end

@protocol DVSUserManagerDelegate <NSObject>

@optional
/**
 *  Allows delegate to modify default validation rules.
 *
 *  @param manager         Instance of user manager.
 *  @param validationRules Default validation rules possible to modify.
 *  @param action          The action for which validation rules will be attached.
 */
- (void)userManager:(DVSUserManager *)manager didPrepareValidationRules:(NSMutableArray *)validationRules forAction:(DVSActionType)action;

@end
