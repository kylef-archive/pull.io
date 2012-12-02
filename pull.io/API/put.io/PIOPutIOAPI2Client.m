//
//  PIOPutIOAPI2Client.m
//  pull.io
//
//  Created by Kyle Fuller on 01/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import "AFJSONRequestOperation.h"

#import "PIOPutIOAPI2Client.h"

static NSString * const kPIOPutIOAPI2APIBaseURLString = @"https://api.put.io/v2/";

@implementation PIOPutIOAPI2Client

- (id)init {
    NSURL *baseURL = [NSURL URLWithString:kPIOPutIOAPI2APIBaseURLString];

    if (self = [super initWithBaseURL:baseURL]) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
    }

    return self;
}

@end
