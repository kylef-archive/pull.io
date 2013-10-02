//
//  Episode+PIOExtensions.m
//  pull.io
//
//  Created by Kyle Fuller on 16/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import "NSManagedObject+KFData.h"
#import "Episode+PIOExtensions.h"

@implementation Episode (PIOExtensions)

+ (KFObjectManager *)managerWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    return [[super managerWithManagedObjectContext:managedObjectContext] orderBy:@[
        [NSSortDescriptor sortDescriptorWithKey:@"season" ascending:YES],
        [NSSortDescriptor sortDescriptorWithKey:@"episode" ascending:YES],
        [NSSortDescriptor sortDescriptorWithKey:@"aired" ascending:YES],
    ]];
}

+ (Episode*)findOrShow:(Show*)show
                Season:(NSNumber*)seasonNumber
               Episode:(NSNumber*)episodeNumber
                 aired:(NSDate*)aired
inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
{
    Episode *episode;

    if (seasonNumber && episodeNumber) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"show == %@ AND episode == %@ AND season == %@", show, episodeNumber, seasonNumber];
        episode = (Episode *)[[[Episode managerWithManagedObjectContext:managedObjectContext] filter:predicate] firstObject:nil];
    }

    if (episode == nil && aired) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"show == %@ AND aired == %@", show, aired];
        episode = (Episode *)[[[Episode managerWithManagedObjectContext:managedObjectContext] filter:predicate] firstObject:nil];
    }

    if (episode == nil) {
        episode = [Episode createInManagedObjectContext:managedObjectContext];
        [episode setShow:show];

        if (seasonNumber) {
            [episode setSeason:seasonNumber];
        }

        if (episodeNumber) {
            [episode setEpisode:episodeNumber];
        }

        if (aired) {
            [episode setAired:aired];
        }
    }
    
    return episode;
}

@end
