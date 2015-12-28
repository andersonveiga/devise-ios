//
//  DVSLoginSignUpViewController.h
//  Devise
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import UIKit;

#import "DVSLoginSignUpFields.h"
#import "DVSUser.h"

/**
 *  Enumeration specifying for what type of action view controller should be customized
 */
typedef NS_ENUM(NSUInteger, DVSRetrieverType) {
    DVSRetrieverTypeLogIn,
    DVSRetrieverTypeSignUp
};


/**
 * Enumeration specifying what action was performed
 */
typedef NS_ENUM(NSUInteger, DVSRetrieverAction) {
    DVSRetrieverActionLogIn,
    DVSRetrieverActionSignUp,
    DVSRetrieverActionPasswordRemind
};

@protocol DVSAccountRetrieverViewControllerDelegate;


/**
 * The DVSAccountRetrieverViewController class presents standard interface for logging or signing up DVSUser
 */
@interface DVSAccountRetrieverViewController : UIViewController

/**
 * The delegate that responds to events of DVSLogInSignUpViewControllerDelegate
 */
@property (weak, nonatomic) id<DVSAccountRetrieverViewControllerDelegate> delegate;

/**
 *  Returns an initialized instance of view controller
 *
 *  @param type Type specifying what action will be launched by controller
 *  @param fields Bitmask specifying elements which are enabled in the view
 *
 *  @return Instance of DVSLoginSignUpViewController class
 */
- (instancetype)initWithType:(DVSRetrieverType)type fields:(DVSAccountRetrieverFields)fields NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

@end

/**
 * The DVSAccountRetrieverViewControllerDelegate protocol defines methods a delegate of DVSLoginSignUpViewController should implement
 */
@protocol DVSAccountRetrieverViewControllerDelegate <NSObject>

/**
 *  Sent to delegate when controller action results with success
 *
 *  @param controller The controller where action finished
 *  @param action Type of finished action
 *  @param user DVSUser object that is result of action
 */
- (void)accountRetrieverViewController:(DVSAccountRetrieverViewController *)controller didSuccessForAction:(DVSRetrieverAction)action user:(DVSUser *)user;

/**
 *  Sent to delegate when controller action finishes with error
 *
 *  @param controller The controller where action finished with error
 *  @param error Object that represents error
 *  @param action Type of action
 */
- (void)accountRetrieverViewController:(DVSAccountRetrieverViewController *)controller didFailWithError:(NSError *)error forAction:(DVSRetrieverAction)action;

/**
 *  Sent to delegate when user did tap dismiss button on controller screen
 *
 *  @param controller The controller that was cancelled
 */
- (void)accountRetrieverViewControllerDidTapDismiss:(DVSAccountRetrieverViewController *)controller;

@end

