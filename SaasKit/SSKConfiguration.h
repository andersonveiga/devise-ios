//
//  SSKConfiguration.h
//
//  Copyright (c) 2014 Netguru Sp. z o.o. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Routes used in SaasKit framework.
typedef NS_ENUM(NSInteger, SSKRoute) {

    /// Login route (default: login).
    SSKRouteLogin = 0,

    /// Register route (default: register).
    SSKRouteRegister,

    /// Forgot password route (default: forgotPassword).
    SSKRouteForgotPassword,
};

/// Logging level of the SaasKit framework.
typedef NS_ENUM(NSInteger, SSKLogLevel) {

    /// Don't log anything, ignore all messages.
    SSKLogLevelNone,

    /// Print all messages using NSLog.
    SSKLogLevelWarning,

    /// Abort the code with the message.
    SSKLogLevelAssert,
};

/// The main configuration object of SaasKit.
@interface SSKConfiguration : NSObject

/// The root URL of the server backend.
@property (strong, nonatomic) NSURL *serverURL;

/// The logging level of the framework (default: SSKLogLevelNone).
@property (assign, nonatomic) SSKLogLevel logLevel;

// /////////////////////////////////////////////////////////////////////////////

/// Returns a shared instance of the configuration object.
+ (instancetype)sharedConfiguration;

/// Creates and returns an instance of configuration object.
///
/// @param serverURL The root URL of the server backend.
- (instancetype)initWithServerURL:(NSURL *)serverURL;

// /////////////////////////////////////////////////////////////////////////////

/// All registered route paths.
@property (strong, nonatomic, readonly) NSDictionary *routePaths;

/// Returns a path for the given route.
///
/// @param route The route, for which you want to get the path.
- (NSString *)pathForRoute:(SSKRoute)route;

/// Sets a path for the given route.
///
/// @param path The path you want to set.
/// @param route The route, for which you want to set the path.
- (void)setPath:(NSString *)path forRoute:(SSKRoute)route;

// /////////////////////////////////////////////////////////////////////////////

/// Logs a message with the level specified by the \c logLevel property.
///
/// @param message The message to log.
- (void)logMessage:(NSString *)message;

@end