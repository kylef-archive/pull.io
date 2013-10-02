//
//  PIOTheTVDBAPIClient.m
//  pull.io
//
//  Created by Kyle Fuller on 16/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import "AFKissXMLRequestOperation.h"

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
        KFObjectManager *manager = [[Show managerWithManagedObjectContext:managedObjectContext] filter:[NSPredicate predicateWithFormat:@"tvdb_id == 0"]];

        manager = [manager orderBy:@[
            [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES],
        ]];

        NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:[manager fetchRequest]
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

                          DDXMLElement *seriesNameElement = [[element elementsForName:@"SeriesName"] lastObject];
                          DDXMLNode *seriesNameNode = [seriesNameElement childAtIndex:0];
                          NSString *seriesName = [seriesNameNode stringValue];

                          DDXMLElement *overviewElement = [[element elementsForName:@"Overview"] lastObject];
                          DDXMLNode *overviewNode = [overviewElement childAtIndex:0];
                          NSString *overview = [overviewNode stringValue];

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

                          [[show managedObjectContext] performWriteBlock:^(NSManagedObjectContext *managedObjectContext) {
                              [show setName:seriesName];
                              [show setTvdb_id:seriesID];
                              [show setOverview:overview];
                              [show setPoster:posterURL];

                              [self updatedEpisodesForShow:show];
                          } success:nil failure:nil];
                      }
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      NSLog(@"TheTVDBAPI findShow inner failure: %@", error);
                  }];

              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"TheTVDBAPI findShow failure: %@", error);
          }];
}

- (void)updatedEpisodesForShow:(Show*)show {
    NSString *path = [kPIOTheTVDBAPIKey stringByAppendingFormat:@"/series/%@/all/", [show tvdb_id]];

    [self getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, DDXMLDocument *XMLDocument) {
        NSArray *nodes = [XMLDocument nodesForXPath:@"//Data/Episode" error:nil];
        NSManagedObjectContext *managedObjectContext = [show managedObjectContext];

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];

        for (DDXMLElement *element in nodes) {
            DDXMLElement *episodeNumberElement = [[element elementsForName:@"EpisodeNumber"] lastObject];
            DDXMLNode *episodeNumberNode = [episodeNumberElement childAtIndex:0];
            NSString *episodeNumberString = [episodeNumberNode stringValue];
            NSInteger episodeNumberInteger = [episodeNumberString integerValue];
            NSNumber *episodeNumber = [NSNumber numberWithInteger:episodeNumberInteger];

            DDXMLElement *seasonNumberElement = [[element elementsForName:@"SeasonNumber"] lastObject];
            DDXMLNode *seasonNumberNode = [seasonNumberElement childAtIndex:0];
            NSString *seasonNumberString = [seasonNumberNode stringValue];
            NSInteger seasonNumberInteger = [seasonNumberString integerValue];
            NSNumber *seasonNumber = [NSNumber numberWithInteger:seasonNumberInteger];

            DDXMLElement *firstAiredElement = [[element elementsForName:@"FirstAired"] lastObject];
            DDXMLNode *firstAiredNode = [firstAiredElement childAtIndex:0];
            NSString *firstAiredString = [firstAiredNode stringValue];
            NSDate *firstAired = [dateFormatter dateFromString:firstAiredString];

            DDXMLElement *nameElement = [[element elementsForName:@"EpisodeName"] lastObject];
            DDXMLNode *nameNode = [nameElement childAtIndex:0];
            NSString *name = [nameNode stringValue];

            [managedObjectContext performWriteBlock:^(NSManagedObjectContext *managedObjectContext) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(season == %@ AND episode == %@) OR (aired != nil AND aired == %@)", seasonNumber, episodeNumber, firstAired];
                NSSet *episodes = [[show episodes] filteredSetUsingPredicate:predicate];

                for (Episode *episode in episodes) {
                    [episode setName:name];
                    [episode setSeason:seasonNumber];
                    [episode setEpisode:episodeNumber];
                    [episode setAired:firstAired];
                }

                if ([episodes count] == 0) {
                    Episode *episode = [Episode createInManagedObjectContext:managedObjectContext];
                    [episode setName:name];
                    [episode setSeason:seasonNumber];
                    [episode setEpisode:episodeNumber];
                    [episode setAired:firstAired];
                    [episode setShow:show];
                }
            } success:nil failure:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"TheTVDBAPI updatedEpisodesForShow failure: %@", error);
    }];
}

@end
