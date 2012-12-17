//
//  PIOFileManager.h
//  pull.io
//
//  Created by Kyle Fuller on 17/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface PIOFileManager : NSObject <NSFetchedResultsControllerDelegate>

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;

@end
