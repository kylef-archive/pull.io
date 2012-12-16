//
//  PIOPutIOAPI2Client.m
//  pull.io
//
//  Created by Kyle Fuller on 01/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import "NSManagedObjectContext+KFData.h"
#import "NSManagedObject+KFData.h"
#import "AFJSONRequestOperation.h"
#import "AFOAuth2Client.h"

#import "PIOPutIOAPI2Client.h"

static NSString * const kPIOPutIOAPI2APIBaseURLString = @"https://api.put.io/v2/";

#define kPIOPutUIAPIOAuthIdentifier @"com.kylefuller.pullio.putio"

#define kPIOPutIOAPIClientID @"233"
#define kPIOPutIOAPIClientSecret @"j5s8tyj08zw4tlkkuxzh"
#define kPIOPutIOAPIClientRedirectURI @"pullio://oauth-callback.put.io"

@interface PIOPutIOAPI2Client ()
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end

@implementation PIOPutIOAPI2Client

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
    NSURL *baseURL = [NSURL URLWithString:kPIOPutIOAPI2APIBaseURLString];

    if (self = [super initWithBaseURL:baseURL clientID:kPIOPutIOAPIClientID secret:kPIOPutIOAPIClientSecret]) {
        _managedObjectContext = managedObjectContext;

        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"application/json"];

        AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:kPIOPutUIAPIOAuthIdentifier];
        if (credential) {
            [self setAccessToken:[credential accessToken]];
//            [self setAuthorizationHeaderWithCredential:credential];
        }
    }

    return self;
}

- (NSURL*)authenticationURL {
    NSString *authentication = [NSString stringWithFormat:@"oauth2/authenticate?client_id=%@&response_type=code&redirect_uri=%@", kPIOPutIOAPIClientID, kPIOPutIOAPIClientRedirectURI];
    NSURL *URL = [NSURL URLWithString:authentication relativeToURL:[self baseURL]];

    return [URL absoluteURL];
}

- (BOOL)hasAuthorization {
    return [self accessToken] != nil;
    return ([self defaultValueForHeader:@"Authorization"] != nil);
}

- (void)authenticateUsingCode:(NSString*)code
                      success:(void (^)(AFOAuthCredential *credential))success
                      failure:(void (^)(NSError *error))failure
{
    [self authenticateUsingOAuthWithPath:@"oauth2/access_token" code:code redirectURI:kPIOPutIOAPIClientRedirectURI success:^(AFOAuthCredential *credential) {
        [AFOAuthCredential storeCredential:credential withIdentifier:kPIOPutUIAPIOAuthIdentifier];
        [self setAccessToken:[credential accessToken]];
        success(credential);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

@end
