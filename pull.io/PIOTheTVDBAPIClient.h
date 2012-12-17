//
//  PIOTheTVDBAPIClient.h
//  pull.io
//
//  Created by Kyle Fuller on 16/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "AFHTTPClient.h"

@interface PIOTheTVDBAPIClient : AFHTTPClient <NSFetchedResultsControllerDelegate>

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;

@end
