//
//  PIOEpisodeListViewController.m
//  pull.io
//
//  Created by Kyle Fuller on 16/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

#import "NSManagedObject+KFData.h"

#import "PIOAppDelegate.h"
#import "PIOPutIOAPI2Client.h"

#import "PIOEpisodeListViewController.h"

#import "Show+PIOExtension.h"
#import "Episode+PIOExtensions.h"
#import "File.h"

@interface PIOEpisodeListViewController ()

@end

@implementation PIOEpisodeListViewController

- (void)setShow:(NSManagedObjectID*)showID {
    Show *show = (Show*)[[self managedObjectContext] objectWithID:showID];

    [self setTitle:[show name]];

    NSFetchRequest *fetchRequest = [Episode fetchRequestInManagedObjectContext:[self managedObjectContext]];
//
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"show == %@", show];
//    [fetchRequest setPredicate:predicate];

    [fetchRequest setSortDescriptors:@[
        [NSSortDescriptor sortDescriptorWithKey:@"season" ascending:YES],
        [NSSortDescriptor sortDescriptorWithKey:@"episode" ascending:YES],
    ]];

    dispatch_async(dispatch_get_main_queue(), ^{
    [self setFetchRequest:fetchRequest sectionNameKeyPath:@"season"];
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (NSString*)fetchedResultsTableController:(KFFetchedResultsTableController *)fetchedResultsTableController
           reuseIdentifierForManagedObject:(NSManagedObject *)managedObject
                               atIndexPath:(NSIndexPath *)indexPath
{
    return @"cell";
}

- (void)fetchedResultsTableController:(KFFetchedResultsTableController *)fetchedResultsTableController
                       configuredCell:(UITableViewCell *)cell
                     forManagedObject:(Episode *)episode
                          atIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = [episode name];

    if (title == nil) {
        title = [NSString stringWithFormat:@"Episode %@", [episode episode]];
    }

    [[cell textLabel] setText:title];
}

- (UITableViewCell*)fetchedResultsTableController:(KFFetchedResultsTableController *)fetchedResultsTableController
                           cellForReuseIdentifier:(NSString *)reuseIdentifier
{
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
}

#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Episode *episode = (Episode*)[[self fetchedResultsTableController] managedObjectForIndexPath:indexPath];
    File *file = [episode file];

    NSURL *URL = [file URL];
    MPMoviePlayerController *playerController = [[MPMoviePlayerController alloc] initWithContentURL:URL];
    [self.view addSubview:playerController.view];
    [playerController setFullscreen:YES animated:YES];
    [playerController play];
    [playerController setControlStyle:MPMovieControlStyleFullscreen];
    [playerController play];

//    [[PIOAppDelegate sharedPutIOAPIClient] getURLForID:fileid success:^(NSURL *URL) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            MPMoviePlayerController *playerController = [[MPMoviePlayerController alloc] initWithContentURL:URL];
//            [self.view addSubview:playerController.view];
//            playerController.fullscreen = YES;
//            [playerController play];
//        });
//    } failure:^(NSError *error) {
//        NSLog(@"fail to get URL %@", error);
//    }];
}

@end
