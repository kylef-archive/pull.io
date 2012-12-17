//
//  PIOFileManager.m
//  pull.io
//
//  Created by Kyle Fuller on 17/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import "NSManagedObjectContext+KFData.h"
#import "NSManagedObject+KFData.h"

#import "PIOShowFilenameMatcher.h"
#import "PIOFileManager.h"

#import "File.h"
#import "Show+PIOExtension.h"
#import "Episode+PIOExtensions.h"

@interface PIOFileManager ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) PIOShowFilenameMatcher *filenameMatcher;

@end

@implementation PIOFileManager

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
    if (self = [super init]) {
        PIOShowFilenameMatcher *filenameMatcher = [[PIOShowFilenameMatcher alloc] init];
        [self setFilenameMatcher:filenameMatcher];

        NSFetchRequest *fetchRequest = [File fetchRequestInManagedObjectContext:managedObjectContext];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"episode = nil AND movie = nil"];
        [fetchRequest setPredicate:predicate];

        [fetchRequest setSortDescriptors:@[
             [NSSortDescriptor sortDescriptorWithKey:@"filename" ascending:YES],
         ]];

        [fetchRequest setIncludesSubentities:YES];

        NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                   managedObjectContext:managedObjectContext
                                                                                                     sectionNameKeyPath:nil
                                                                                                              cacheName:nil];
        [self setFetchedResultsController:fetchedResultsController];
        [fetchedResultsController setDelegate:self];

        NSManagedObjectContext *parentContext = [managedObjectContext parentContext];
        if (parentContext) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(mergeChanges:)
                                                         name:NSManagedObjectContextDidSaveNotification
                                                       object:parentContext];
        }

        [managedObjectContext performBlock:^{
            NSError *error;
            [fetchedResultsController performFetch:&error];

            if (error) {
                NSLog(@"PIOFileManager performFetch error: %@", error);
            } else {
                for (File *file in [fetchedResultsController fetchedObjects]) {
                    [self matchFile:file];
                }
            }
        }];
    }

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notifications

- (void)mergeChanges:(NSNotification*)notification {
    NSManagedObjectContext *managedObjectContext = [[self fetchedResultsController] managedObjectContext];

    [managedObjectContext performBlock:^{
        [managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    }];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(File*)file
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    if (type == NSFetchedResultsChangeInsert || type == NSFetchedResultsChangeUpdate) {
        [self matchFile:file];
    }
}

- (void)matchFile:(File*)file {
    if ([file episode] == nil) {
        NSManagedObjectContext *managedObjectContext = [[self fetchedResultsController] managedObjectContext];
        
        PIOShowFilenameMatch *match = [[self filenameMatcher] matchFilename:[file filename]];
        
        if (match) {
            Show *show = [Show findOrCreate:[match seriesName]
                     inManagedObjectContext:managedObjectContext];
            
            Episode *episode = [Episode findOrShow:show
                                            Season:[match seasonNumber]
                                           Episode:[[match episodeNumbers] lastObject]
                            inManagedObjectContext:managedObjectContext];
            
            [file setEpisode:episode];
            
            [managedObjectContext nestedSave];
        }
    }
}

@end