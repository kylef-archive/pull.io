//
//  Video.h
//  pull.io
//
//  Created by Kyle Fuller on 31/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class File;

@interface Video : NSManagedObject

@property (nonatomic, retain) NSNumber * watched;
@property (nonatomic, retain) NSNumber * playback_time;
@property (nonatomic, retain) File *file;

@end
