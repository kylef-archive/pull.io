//
//  PutIOFile.m
//  pull.io
//
//  Created by Kyle Fuller on 15/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import "PIOAppDelegate.h"
#import "PIOPutIOAPI2Client.h"

#import "PutIOFile.h"


@implementation PutIOFile

@dynamic id;

- (NSURL*)URL {
    return [[PIOAppDelegate sharedPutIOAPIClient] URLForFileID:[self valueForKey:@"id"]];
}

@end
