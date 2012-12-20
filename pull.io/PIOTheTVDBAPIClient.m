//
//  PIOTheTVDBAPIClient.m
//  pull.io
//
//  Created by Kyle Fuller on 16/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import "AFKissXMLRequestOperation.h"

#import "NSManagedObject+KFData.h"
#import "NSManagedObjectContext+KFData.h"

#import "PIOTheTVDBAPIClient.h"

#import "Show+PIOExtension.h"
#import "Episode+PIOExtensions.h"

#define kPIOTheTVDBAPIBaseURL @"http://thetvdb.com/api/"
#define kPIOTheTVDBAPIKey @"47C2D49D35CBB3F0"

@interface PIOTheTVDBAPIClient ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation PIOTheTVDBAPIClient

- (id)init {
    NSURL *baseURL = [NSURL URLWithString:kPIOTheTVDBAPIBaseURL];
    if (self = [super initWithBaseURL:baseURL]) {
        [self registerHTTPOperationClass:[AFKissXMLRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"application/xml"];
    }

    return self;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
    if (self = [self init]) {
        NSFetchRequest *fetchRequest = [Show fetchRequestInManagedObjectContext:managedObjectContext];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tvdb_id == 0"];
        [fetchRequest setPredicate:predicate];

        [fetchRequest setSortDescriptors:@[
            [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES],
        ]];

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
                NSLog(@"PIOTheTVDBAPIClient performFetch error: %@", error);
            } else {
                for (Show *show in [fetchedResultsController fetchedObjects]) {
                    [self updateShow:show];
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
   didChangeObject:(Show*)show
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    if (type == NSFetchedResultsChangeInsert || type == NSFetchedResultsChangeUpdate) {
        [self updateShow:show];
    }
}

#pragma mark -

- (void)updateShow:(Show*)show {
    NSDictionary *parameters = @{
        @"seriesname": [show name],
    };

    [self getPath:@"GetSeries.php"
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, DDXMLDocument *XMLDocument) {
              NSArray *nodes = [XMLDocument nodesForXPath:@"//Data/Series" error:nil];

              if ([nodes count]) {
                  DDXMLElement *element = [nodes objectAtIndex:0];

                  DDXMLElement *seriesIDElement = [[element elementsForName:@"seriesid"] lastObject];
                  DDXMLNode *seriesIDNode = [seriesIDElement childAtIndex:0];
                  NSString *seriesIDString = [seriesIDNode stringValue];
                  NSInteger seriesIDInteger = [seriesIDString integerValue];
                  NSNumber *seriesID = [NSNumber numberWithInteger:seriesIDInteger];

                  NSString *path = [kPIOTheTVDBAPIKey stringByAppendingFormat:@"/series/%@/", seriesID];

                  [self getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, DDXMLDocument *XMLDocument) {
                      NSArray *nodes = [XMLDocument nodesForXPath:@"//Data/Series" error:nil];

                      if ([nodes count]) {
                          DDXMLElement *element = [nodes objectAtIndex:0];

                          DDXMLElement *overviewElement = [[element elementsForName:@"Overview"] lastObject];
                          DDXMLNode *overviewNode = [overviewElement childAtIndex:0];
                          NSString *overview = [overviewNode stringValue];;

                          DDXMLElement *posterElement = [[element elementsForName:@"poster"] lastObject];
                          DDXMLNode *posterNode = [posterElement childAtIndex:0];
                          NSString *poster = [posterNode stringValue];

                          NSString *posterURL;
                          if (poster) {
                              posterURL = [@"http://thetvdb.com/banners/" stringByAppendingString:poster];
                          }

                          DDXMLElement *imdbIDElement = [[element elementsForName:@"IMDB_ID"] lastObject];
                          DDXMLNode *imdbIDNode = [imdbIDElement childAtIndex:0];
                          NSString *imdbID = [imdbIDNode stringValue];

                          [[show managedObjectContext] performWriteBlock:^{
                              [show setTvdb_id:seriesID];
                              [show setOverview:overview];
                              [show setPoster:posterURL];
                          }];
                      }
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      NSLog(@"TheTVDBAPI findShow inner failure: %@", error);
                  }];

              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"TheTVDBAPI findShow failure: %@", error);
          }];
}

@end
