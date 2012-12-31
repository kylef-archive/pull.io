//
//  File.h
//  pull.io
//
//  Created by Kyle Fuller on 31/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Video;

@interface File : NSManagedObject

@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) Video *video;

- (NSURL*)URL;

@end
