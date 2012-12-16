//
//  Episode+PIOExtensions.h
//  pull.io
//
//  Created by Kyle Fuller on 16/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import "Episode.h"

@class Show;

@interface Episode (PIOExtensions)

+ (Episode*)findOrShow:(Show*)show
                Season:(NSNumber*)seasonNumber
               Episode:(NSNumber*)episodeNumber
inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;

@end
