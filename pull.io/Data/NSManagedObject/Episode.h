//
//  Episode.h
//  pull.io
//
//  Created by Kyle Fuller on 19/01/2013.
//  Copyright (c) 2013 Kyle Fuller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Video.h"

@class Show;

@interface Episode : Video

@property (nonatomic, retain) NSNumber * episode;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * season;
@property (nonatomic, retain) NSDate * aired;
@property (nonatomic, retain) Show *show;

@end
