//
//  Show+PIOExtension.h
//  pull.io
//
//  Created by Kyle Fuller on 16/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import "Show.h"

@interface Show (PIOExtension)

+ (Show*)findOrCreate:(NSString*)showName inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;

@end
