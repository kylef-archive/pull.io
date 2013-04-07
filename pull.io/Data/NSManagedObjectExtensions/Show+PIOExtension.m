//
//  Show+PIOExtension.m
//  pull.io
//
//  Created by Kyle Fuller on 16/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import "Show+PIOExtension.h"

@implementation Show (PIOExtension)

+ (Show*)findOrCreate:(NSString*)showName inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name LIKE[c] %@", showName];
    Show *show = [Show findSingleWithPredicate:predicate inManagedObjectContext:managedObjectContext];

    if (show == nil) {
        show = [Show createInManagedObjectContext:managedObjectContext];
        [show setName:showName];
    }

    return show;
}

@end
