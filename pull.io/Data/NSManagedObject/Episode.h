//
//  Episode.h
//  pull.io
//
//  Created by Kyle Fuller on 15/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class File;

@interface Episode : NSManagedObject

@property (nonatomic, retain) NSNumber * episode;
@property (nonatomic, retain) NSNumber * name;
@property (nonatomic, retain) NSString * season;
@property (nonatomic, retain) NSNumber * watched;
@property (nonatomic, retain) File *file;
@property (nonatomic, retain) NSManagedObject *show;

@end
