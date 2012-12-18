//
//  Episode.h
//  pull.io
//
//  Created by Kyle Fuller on 18/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Video.h"

@class File, Show;

@interface Episode : Video

@property (nonatomic, retain) NSNumber * episode;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * season;
@property (nonatomic, retain) File *file;
@property (nonatomic, retain) Show *show;

@end
