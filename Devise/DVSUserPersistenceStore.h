//
//  DVSUserPersistenceStore.h
//  Devise
//
//  Created by Wojciech Trzasko on 13.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DVSUser.h"

@class DVSConfiguration;

@interface DVSUserPersistenceStore : NSObject

/**
 *  A locally saved user object (if any).
 *  Notice that localUser will be taken only once from keychain store until will be nilled.
 */
@property (strong, nonatomic) DVSUser *localUser;

/**
 *  Default Initializer for DVSUserPersistenceStore class.
 *
 *  @param configuration The configuration used to initialize DVSUserPersistenceStore.
 */
- (instancetype)initWithConfiguration:(DVSConfiguration *)configuration NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

/**
 *  Returns fresh copy of user model taken from keychain store. If model doesn't exist, returns nil.
 *  Notice that persistentUser can be different from localUser.
 */
- (DVSUser *)persistentUser;

@end
