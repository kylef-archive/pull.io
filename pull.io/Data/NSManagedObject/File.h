//
//  File.h
//  pull.io
//
//  Created by Kyle Fuller on 15/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface File : NSManagedObject

@property (nonatomic, retain) NSString *filename;
@property (nonatomic, retain) NSManagedObject *movie;
@property (nonatomic, retain) NSManagedObject *episode;

- (NSURL*)URL;

@end
