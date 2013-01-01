//
//  PIOEpisodeListViewController.m
//  pull.io
//
//  Created by Kyle Fuller on 16/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import "NSManagedObject+KFData.h"
#import "NSString+PIOExtensions.h"

#import "PIOAppDelegate.h"
#import "PIOPutIOAPI2Client.h"

#import "PIOEpisodeListViewController.h"
#import "PIOVideoPlayerViewController.h"

#import "Show+PIOExtension.h"
#import "Episode+PIOExtensions.h"
#import "File.h"

@interface PIOEpisodeListViewController () <UIActionSheetDelegate>

@property (nonatomic, strong) Episode *selectedEpisode;

@end

@implementation PIOEpisodeListViewController

- (void)setShow:(NSManagedObjectID*)showID {
    Show *show = (Show*)[[self managedObjectContext] objectWithID:showID];

    [[self managedObjectContext] performBlock:^{
        NSString *title = [show name];
        NSString *overview = [show overview];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self setTitle:title];

            if ([overview length] > 0) {
                UIFont *font = [UIFont systemFontOfSize:16];
                CGSize size = [[self tableView] frame].size;
                CGSize textSize = [overview sizeWithFont:font constrainedToSize:CGSizeMake(size.width - 20, MAXFLOAT)];
                size.height = textSize.height + 20;

                UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
                UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, textSize.width, textSize.height)];
                [descriptionLabel setFont:font];
                [descriptionLabel setNumberOfLines:0];
                [descriptionLabel setText:overview];
                [headerView addSubview:descriptionLabel];

                UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0, size.height - 1, size.width, 1)];
                [borderView setBackgroundColor:[UIColor lightGrayColor]];
                [headerView addSubview:borderView];

                [[self tableView] setTableHeaderView:headerView];
            }
        });
    }];

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

- (NSString*)tableView:(UITableView *)tableView
    reuseIdentifierForManagedObject:(NSManagedObject *)managedObject
           atIndexPath:(NSIndexPath *)indexPath
{
    return @"cell";
}

- (void)tableView:(UITableView*)tableView
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

    BOOL isWatched = [[episode watched] boolValue];
    [cell setAccessoryType:(isWatched ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone)];
}

- (UITableViewCell*)tableView:(UITableView*)tableView
       cellForReuseIdentifier:(NSString *)reuseIdentifier
{
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
}

#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Episode *episode = (Episode*)[[self fetchedResultsController] objectAtIndexPath:indexPath];

    double playbackTime = [[episode playback_time] doubleValue];

    if (playbackTime > 1.0) {
        [self setSelectedEpisode:episode];

        NSString *resumeString = [NSString stringWithFormat:NSLocalizedString(@"PLAY_TIMESTAMP", nil), [NSString stringWithTimeInterval:playbackTime]];

        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:nil
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:resumeString,
                                                                          NSLocalizedString(@"PLAY_FROM_START", nil), nil];

        [actionSheet showFromRect:[tableView rectForRowAtIndexPath:indexPath]
                           inView:tableView
                         animated:YES];
    } else {
        [self playEpisode:episode resumeFromPreviousPlayback:NO];
    }
}

- (void)playEpisode:(Episode*)episode resumeFromPreviousPlayback:(BOOL)resume {
    PIOVideoPlayerViewController *playerViewController = [[PIOVideoPlayerViewController alloc] initWithVideo:episode];
    [playerViewController setResumeFromPreviousPlayback:resume];
    [self presentMoviePlayerViewControllerAnimated:playerViewController];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self playEpisode:[self selectedEpisode] resumeFromPreviousPlayback:YES];
            break;
        case 1:
            [self playEpisode:[self selectedEpisode] resumeFromPreviousPlayback:NO];
            break;
    }

    [self setSelectedEpisode:nil];
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet {
    [self setSelectedEpisode:nil];
}

@end
