//
//  Show.h
//  pull.io
//
//  Created by Kyle Fuller on 17/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Episode;

@interface Show : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * tvdb_id;
@property (nonatomic, retain) NSString * overview;
@property (nonatomic, retain) NSSet *episodes;
@end

@interface Show (CoreDataGeneratedAccessors)

- (void)addEpisodesObject:(Episode *)value;
- (void)removeEpisodesObject:(Episode *)value;
- (void)addEpisodes:(NSSet *)values;
- (void)removeEpisodes:(NSSet *)values;

@end
