//
//  File.m
//  pull.io
//
//  Created by Kyle Fuller on 31/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import "File.h"
#import "Video.h"


@implementation File

@dynamic filename;
@dynamic video;

- (NSURL*)URL {
    return nil;
}

+ (KFObjectManager *)managerWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    return [[super managerWithManagedObjectContext:managedObjectContext] orderBy:@[
        [NSSortDescriptor sortDescriptorWithKey:@"filename" ascending:YES],
    ]];
}

@end
