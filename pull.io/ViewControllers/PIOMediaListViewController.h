//
//  PIOMediaListViewController.h
//  pull.io
//
//  Created by Kyle Fuller on 16/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import "KFDataCollectionViewController.h"

@interface PIOMediaListViewController : KFDataCollectionViewController

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
