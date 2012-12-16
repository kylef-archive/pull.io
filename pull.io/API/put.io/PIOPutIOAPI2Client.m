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
#import "PutIOFile.h"
#import "Show+PIOExtension.h"
#import "Episode+PIOExtensions.h"
#import "PIOShowFilenameMatcher.h"

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

#pragma mark - Mis placed API call
        [self getFiles];
    } failure:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark -

- (NSURL*)URLForFileID:(NSString*)fileID {
    NSString *path = [NSString stringWithFormat:@"files/%@/download", fileID];
    
    NSDictionary *parameters = @{
    @"oauth_token": [self accessToken],
    };

    [[self baseURL] URLByAppendingPathComponent:path];
    
    
    NSURL *url = [NSURL URLWithString:path relativeToURL:[self baseURL]];
	url = [NSURL URLWithString:[[url absoluteString] stringByAppendingFormat:[path rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@", AFQueryStringFromParametersWithEncoding(parameters, self.stringEncoding)]];
    return url;
}

- (void)getFiles {
    NSDictionary *parameters = @{
        @"oauth_token": [self accessToken],
    };

    [self getPath:@"files/list" parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSManagedObjectContext *managedObjectContext = [self managedObjectContext];

        [managedObjectContext performWriteBlock:^{
            PIOShowFilenameMatcher *filenameMatcher = [[PIOShowFilenameMatcher alloc] init];

            NSArray *files = [responseObject objectForKey:@"files"];
            for (NSDictionary *file in files) {
                NSString *contentType = [file objectForKey:@"content_type"];

                if ([contentType isEqualToString:@"video/mp4"]) {
                    NSNumber *idx = [file objectForKey:@"id"];
                    NSString *filename = [file objectForKey:@"name"];

                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", idx];
                    PutIOFile *managedFile = (PutIOFile*)[PutIOFile objectForPredicate:predicate
                                                    inManagedObjectContext:managedObjectContext];

                    if (managedFile == nil) {
                        managedFile = (PutIOFile*)[PutIOFile createInContext:managedObjectContext];
                        [managedFile setId:idx];
                        [managedFile setFilename:filename];
                    }

                    // TODO: Move this out of the API, it should be generic with other "providers"
                    if ([managedFile episode] == nil) {
                        PIOShowFilenameMatch *match = [filenameMatcher matchFilename:[managedFile filename]];
                        NSLog(@"Match: %@", match);

                        Show *show = [Show findOrCreate:[match seriesName]
                                 inManagedObjectContext:managedObjectContext];
                        Episode *episode = [Episode findOrShow:show
                                                        Season:[match seasonNumber]
                                                       Episode:[[match episodeNumbers] lastObject]
                                        inManagedObjectContext:managedObjectContext];
                        
                        [managedFile setEpisode:episode];

                        [managedObjectContext save];
                    }
                }
            }
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Get files failed: %@", error);
    }];
}

@end
