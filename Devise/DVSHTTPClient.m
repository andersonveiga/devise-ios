//
//  DVSHTTPClient.m
//  
//  Copyright (c) 2014 Netguru Sp. z o.o. All rights reserved.
//

#import "DVSHTTPClient.h"
#import "DVSConfiguration.h"
#import "NSURLSession+Devise+Private.h"

typedef void (^DVSHTTPClientRetriableBlock)(DVSHTTPClientCompletionBlock block);

@interface DVSHTTPClient ()

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSMutableDictionary *oAuthHTTPHeaderFields;

@end

#pragma mark -

@implementation DVSHTTPClient

#pragma mark - Object lifecycle

- (instancetype)initWithConfiguration:(DVSConfiguration *)configuration {
    self = [super init];
    if (self == nil) return nil;

    _configuration = configuration;
    _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    _oAuthHTTPHeaderFields = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (instancetype)init {
    return [self initWithConfiguration:nil];
}

- (void)dealloc {
    [self cancelAllRequests];
}

#pragma mark - Request management

- (void)POST:(NSString *)path parameters:(NSDictionary *)parameters completion:(DVSHTTPClientCompletionBlock)completion {
    [self executeRetriableBlock:^(DVSHTTPClientCompletionBlock retry) {

        NSURLRequest *request = [self requestWithPath:path method:@"POST" JSONObject:parameters];
        [self.session performDataTaskWithRequest:request completion:retry];
        
    } completion:completion];
}

- (void)PUT:(NSString *)path parameters:(NSDictionary *)parameters completion:(DVSHTTPClientCompletionBlock)completion {
    [self executeRetriableBlock:^(DVSHTTPClientCompletionBlock retry) {

        NSURLRequest *request = [self requestWithPath:path method:@"PUT" JSONObject:parameters];
        [self.session performDataTaskWithRequest:request completion:retry];
        
    } completion:completion];
}

- (void)DELETE:(NSString *)path parameters:(NSDictionary *)parameters completion:(DVSHTTPClientCompletionBlock)completion {
    [self executeRetriableBlock:^(DVSHTTPClientCompletionBlock retry) {
        
        NSURLRequest *request = [self requestWithPath:path method:@"DELETE" JSONObject:parameters];
        [self.session performDataTaskWithRequest:request completion:retry];
        
    } completion:completion];
}

- (void)cancelAllRequests {
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        for (NSURLSessionTask *task in dataTasks) {
            [task cancel];
        }
    }];
}

#pragma mark - Headers

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    value ? self.oAuthHTTPHeaderFields[field] = value : [self.oAuthHTTPHeaderFields removeObjectForKey:field];
}

#pragma mark - Helpers

- (NSURLRequest *)requestWithPath:(NSString *)path method:(NSString *)method JSONObject:(id)json {
    
    NSAssert(self.configuration.baseURL != nil, @"Server base URL cannot be nil.");
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[self absoluteURLForPath:path]];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [self.oAuthHTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(NSString *field, NSString *value, BOOL *stop) {
        [request addValue:self.oAuthHTTPHeaderFields[field] forHTTPHeaderField:field];
    }];
    
    [request setHTTPMethod:method];
        
    if (json) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:json options:kNilOptions error:&error];
        if (data && !error) {
            [request setHTTPBody:data];
        }
    }
    
    return [request copy];
}

- (NSURL *)absoluteURLForPath:(NSString *)path {
    return [NSURL URLWithString:[self.configuration.baseURL URLByAppendingPathComponent:path].absoluteString];
}

- (void)executeRetriableBlock:(DVSHTTPClientRetriableBlock)retriable completion:(DVSHTTPClientCompletionBlock)completion {
    static NSUInteger retriesCounter = 0;
    retriable(^(id responseObject, NSError *error) {
        if (error == nil || retriesCounter == self.configuration.numberOfRetries) {
            if (completion != NULL) completion(responseObject, error);
            retriesCounter = 0;
        } else {
            retriesCounter++;
            NSTimeInterval waitDuration = self.configuration.retryThresholdDuration;
            dispatch_time_t gcdDuration = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(waitDuration * NSEC_PER_SEC));
            __weak typeof(self) weakSelf = self;
            dispatch_after(gcdDuration, dispatch_get_main_queue(), ^{
                [weakSelf executeRetriableBlock:retriable completion:completion];
            });
        }
    });
}

@end
