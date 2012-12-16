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
inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"show == %@ AND episode == %@ AND season == %@", show, episodeNumber, seasonNumber];;
    Episode *episode = (Episode*)[Episode objectForPredicate:predicate inManagedObjectContext:managedObjectContext];
    
    if (episode == nil) {
        episode = (Episode*)[Episode createInContext:managedObjectContext];
        [episode setShow:(NSManagedObject*)show];
        [episode setSeason:seasonNumber];
        [episode setEpisode:episodeNumber];
    }
    
    return episode;
}

@end
