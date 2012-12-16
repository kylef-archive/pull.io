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

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"show == %@", show];
    [fetchRequest setPredicate:predicate];

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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

    if (title) {
        title = [NSString stringWithFormat:@"%@ %@", [episode episode], title];
    } else {
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
    [[self view] addSubview:[playerController view]];
    [playerController setFullscreen:YES];
    [playerController setMovieSourceType:MPMovieSourceTypeStreaming];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerWillExitFullscreen:)
                                                 name:MPMoviePlayerWillExitFullscreenNotification
                                               object:playerController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerFinished:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:playerController];

    [playerController prepareToPlay];
    [playerController play];
}

- (void)moviePlayerWillExitFullscreen:(NSNotification*)notification {
    MPMoviePlayerController *player = [notification object];

    [player stop];
    [[player view] removeFromSuperview];

    // Update "watched"
}

- (void)moviePlayerFinished:(NSNotification*)notification{
    MPMoviePlayerController *player = [notification object];

    [player stop];
    [[player view] removeFromSuperview];
}

@end
