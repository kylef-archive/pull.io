//
//  PIOTraktAPIClient.m
//  pull.io
//
//  Created by Kyle Fuller on 02/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import "AFJSONRequestOperation.h"

#import "PIOTraktAPIClient.h"

static NSString * const kPIOTraktAPIBaseURLString = @"http://api.trakt.tv/";

@implementation PIOTraktAPIClient

- (id)init {
    NSURL *baseURL = [NSURL URLWithString:kPIOTraktAPIBaseURLString];
    
    if (self = [super initWithBaseURL:baseURL]) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
    }
    
    return self;
}

@end
