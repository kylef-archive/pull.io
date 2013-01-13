//
//  Video.h
//  pull.io
//
//  Created by Kyle Fuller on 13/01/2013.
//  Copyright (c) 2013 Kyle Fuller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class File;

@interface Video : NSManagedObject

@property (nonatomic, retain) NSNumber * playback_time;
@property (nonatomic, retain) NSNumber * watched;
@property (nonatomic, retain) NSSet *file;
@end

@interface Video (CoreDataGeneratedAccessors)

- (void)addFileObject:(File *)value;
- (void)removeFileObject:(File *)value;
- (void)addFile:(NSSet *)values;
- (void)removeFile:(NSSet *)values;

@end
