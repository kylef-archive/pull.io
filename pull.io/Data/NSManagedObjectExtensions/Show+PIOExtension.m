//
//  Show+PIOExtension.m
//  pull.io
//
//  Created by Kyle Fuller on 16/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import "Show+PIOExtension.h"

@implementation Show (PIOExtension)

+ (KFObjectManager *)managerWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    NSArray *sortDescriptors = @[
        [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]
    ];

    return [[super managerWithManagedObjectContext:managedObjectContext] orderBy:sortDescriptors];
}

+ (Show*)findOrCreate:(NSString*)showName inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
    Show *show = (Show *)[[[self managerWithManagedObjectContext:managedObjectContext] filter:[NSPredicate predicateWithFormat:@"name LIKE[c] %@", showName]] firstObject:nil];

    if (show == nil) {
        show = [Show createInManagedObjectContext:managedObjectContext];
        [show setName:showName];
    }

    return show;
}

@end
