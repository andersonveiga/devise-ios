//
//  DVSUser.m
//  
//  Copyright (c) 2014 Netguru Sp. z o.o. All rights reserved.
//

#import "DVSAPIManager.h"
#import "DVSUser.h"
#import "DVSUser+Persistence.h"
#import "DVSValidator.h"

@interface DVSUser ()

@property (strong, nonatomic) NSArray *additionalRequestParameters;

@property (strong, nonatomic, readwrite) NSString *identifier;
@property (strong, nonatomic, readwrite) NSString *sessionToken;

@end

@implementation DVSUser

#pragma mark - Public Methods

- (instancetype)init {
    self = [super init];
    if (self) {
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:5];
        for (int i = 0; i <= DVSActionUpdate; i++) {
            array[i] = [NSMutableDictionary dictionary];
        }
        _additionalRequestParameters = [array copy];
    }
    return self;
}

+ (instancetype)user {
    return [[self alloc] init];
}

- (id)objectForKey:(NSString *)key action:(DVSActionType)actionType {
    return self.additionalRequestParameters[actionType][key];
}

- (NSDictionary *)objectsForAction:(DVSActionType)actionType {
    return self.additionalRequestParameters[actionType];
}

- (void)setObject:(id)object forKey:(NSString *)key action:(DVSActionType)actionType {
    self.additionalRequestParameters[actionType][key] = object;
}

- (void)setObjects:(NSDictionary *)objects forAction:(DVSActionType)actionType {
    [self.additionalRequestParameters[actionType] addEntriesFromDictionary:objects];
}

#pragma mark - Login Methods

- (void)loginWithSuccess:(DVSVoidBlock)success failure:(DVSErrorBlock)failure {
    
    NSArray *rules = @[DVSValidate(@"password").required(),
                       DVSValidate(@"email").required().emailSyntax()];
    
    [self validateUsingRules:rules forAction:DVSActionLogin success:^{
        [DVSAPIManager loginUser:self withSuccess:success failure:failure];
    } failure:failure];
}

- (void)loginWithExtraParams:(DVSExtraParamsBlock)params success:(DVSVoidBlock)success failure:(DVSErrorBlock)failure {
    
    [self setObjects:params() forAction:DVSActionLogin];
    [self loginWithSuccess:success failure:failure];
}

#pragma mark - Remind Password Methods

- (void)remindPasswordWithSuccess:(DVSVoidBlock)success failure:(DVSErrorBlock)failure {

    NSArray *rules = @[DVSValidate(@"email").required().emailSyntax()];
    
    [self validateUsingRules:rules forAction:DVSActionRemindPassword success:^{
        [DVSAPIManager remindPasswordForUser:self withSuccess:success failure:failure];
    } failure:failure];
}

- (void)remindPasswordWithExtraParams:(DVSExtraParamsBlock)params success:(DVSVoidBlock)success failure:(DVSErrorBlock)failure {

    [self setObjects:params() forAction:DVSActionRemindPassword];
    [self remindPasswordWithSuccess:success failure:failure];
}

+ (void)remindPasswordWithEmail:(NSString *)email success:(DVSVoidBlock)success failure:(DVSErrorBlock)failure {

    DVSUser *user = [DVSUser user];
    user.email = email;
    [user remindPasswordWithSuccess:success failure:failure];
}

#pragma mark - Register Methods

- (void)registerWithSuccess:(DVSVoidBlock)success failure:(DVSErrorBlock)failure {
    
    NSArray *rules = @[DVSValidate(@"password").required(),
                       DVSValidate(@"email").required().emailSyntax()];
    
    [self validateUsingRules:rules forAction:DVSActionRegistration success:^{
        [DVSAPIManager registerUser:self withSuccess:success failure:failure];
    } failure:failure];
}

- (void)registerWithExtraParams:(DVSExtraParamsBlock)params success:(DVSVoidBlock)success failure:(DVSErrorBlock)failure {

    [self setObjects:params() forAction:DVSActionRegistration];
    [self registerWithSuccess:success failure:failure];
}

#pragma mark - Change Password Methods

- (void)changePasswordWithSuccess:(DVSVoidBlock)success failure:(DVSErrorBlock)failure {
    
    NSArray *rules = @[DVSValidate(@"password").required()];
    
    [self validateUsingRules:rules forAction:DVSActionChangePassword success:^{
        [DVSAPIManager changePasswordForUser:self withSuccess:success failure:failure];
    } failure:failure];
}

- (void)changePasswordWithExtraParams:(DVSExtraParamsBlock)params success:(DVSVoidBlock)success failure:(DVSErrorBlock)failure {
    [self setObjects:params() forAction:DVSActionChangePassword];
    [self changePasswordWithSuccess:success failure:failure];
}

#pragma mark - Update Methods

- (void)updateWithSuccess:(DVSVoidBlock)success failure:(DVSErrorBlock)failure {
    
    NSArray *rules = @[DVSValidate(@"email").required().emailSyntax()];
    
    [self validateUsingRules:rules forAction:DVSActionUpdate success:^{
        [DVSAPIManager updateUser:self withSuccess:success failure:failure];
    } failure:failure];
}

- (void)updateWithExtraParams:(DVSExtraParamsBlock)params success:(DVSVoidBlock)success failure:(DVSErrorBlock)failure {
    [self setObjects:params() forAction:DVSActionUpdate];
    [self updateWithSuccess:success failure:failure];
}

#pragma mark - Delete Account Methods

- (void)deleteAccountWithSuccess:(DVSVoidBlock)success failure:(DVSErrorBlock)failure {
    
    [DVSAPIManager deleteUser:self withSuccess:^{
        [[self class] removeLocalUser];
        success();
    } failure:failure];
}

#pragma mark - Private Methods

- (void)validateUsingRules:(NSArray *)rules forAction:(DVSActionType)action success:(DVSVoidBlock)success failure:(DVSErrorBlock)failure {
    
    NSError *error;
    BOOL validated = [DVSValidator validateModel:self error:&error usingRules:^NSArray *{
        
        
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(additionalValidationRulesForAction:)]) {
            NSArray *array = [self.dataSource additionalValidationRulesForAction:action];
            return [self mergeDefaultRules:rules withCustomRules:array];
        }
        return rules;
    }];
    validated ? success() : failure(error);
}

- (NSArray *)mergeDefaultRules:(NSArray *)defaultRules withCustomRules:(NSArray *)customRules {
    //Quick fix -- has to be improved
    NSMutableArray *array = [defaultRules mutableCopy];
    [array addObjectsFromArray:customRules];
    
    for (DVSPropertyValidator *validatorA in defaultRules) {
        for (DVSPropertyValidator *validatorB in customRules) {
            if ([validatorA.propertyName isEqualToString:validatorB.propertyName]) {
                [validatorA.validators addObjectsFromArray:validatorB.validators];
                validatorA.descriptions = validatorB.descriptions;
                [array removeObject:validatorB];
                break;
            }
        }
    }
    return array;
}
                                         

@end