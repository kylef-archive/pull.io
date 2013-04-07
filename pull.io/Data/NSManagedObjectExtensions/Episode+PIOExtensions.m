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

+ (Episode*)findOrShow:(Show*)show
                Season:(NSNumber*)seasonNumber
               Episode:(NSNumber*)episodeNumber
                 aired:(NSDate*)aired
inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
{
    Episode *episode;

    if (seasonNumber && episodeNumber) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"show == %@ AND episode == %@ AND season == %@", show, episodeNumber, seasonNumber];
        episode = [Episode findSingleWithPredicate:predicate inManagedObjectContext:managedObjectContext];
    }

    if (episode == nil && aired) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"show == %@ AND aired == %@", show, aired];
        episode = [Episode findSingleWithPredicate:predicate inManagedObjectContext:managedObjectContext];
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
