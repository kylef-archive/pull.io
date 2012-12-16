//
//  PIOPutIOAPI2Client.h
//  pull.io
//
//  Created by Kyle Fuller on 01/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFOAuth2Client.h"

@interface PIOPutIOAPI2Client : AFOAuth2Client

- (NSURL*)authenticationURL;
- (BOOL)hasAuthorization;
- (void)authenticateUsingCode:(NSString*)code
                      success:(void (^)(AFOAuthCredential *credential))success
                      failure:(void (^)(NSError *error))failure;

@end
