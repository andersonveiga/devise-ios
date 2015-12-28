//
//  DVSAccountStore.h
//  Devise
//
//  Created by Pawel Bialecki on 09.03.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import Accounts;

typedef void(^DVSAccountStoreBlock)(ACAccount *account, NSError *error);

@interface DVSFacebookAccountStore : ACAccountStore

/**
 *  Designated initializer.
 *
 *  @param appIDKey     Facebook App ID, as it appears on the Facebook website.
 *  @param permissions An array of of the permissions you're requesting.
 *
 *  @return Instance of ACAccountStore.
 */
- (instancetype)initWithAppID:(NSString *)appID permissions:(NSArray *)permissions NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

/**
 * Request access to facebook account configured on the device
 */
- (void)requestAccessWithCompletion:(DVSAccountStoreBlock)completion;

@end
