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

    [[self managedObjectContext] performBlock:^{
        NSString *title = [show name];
        NSString *overview = [show overview];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self setTitle:title];

            UIFont *font = [UIFont systemFontOfSize:16];
            CGSize size = [[self tableView] frame].size;
            size = [overview sizeWithFont:font constrainedToSize:CGSizeMake(size.width, MAXFLOAT)];
            
            UILabel *headerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
            [headerView setFont:font];
            [headerView setNumberOfLines:0];
            [headerView setText:overview];
            [[self tableView] setTableHeaderView:headerView];
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
}

- (UITableViewCell*)tableView:(UITableView*)tableView
       cellForReuseIdentifier:(NSString *)reuseIdentifier
{
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
}

#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Episode *episode = (Episode*)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    File *file = [episode file];

    NSURL *URL = [file URL];

    MPMoviePlayerViewController *playerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:URL];
    [self presentMoviePlayerViewControllerAnimated:playerViewController];
}

@end
