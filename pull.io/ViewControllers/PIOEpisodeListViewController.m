//
//  PIOEpisodeListViewController.m
//  pull.io
//
//  Created by Kyle Fuller on 16/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import "NSString+PIOExtensions.h"

#import "PIOAppDelegate.h"
#import "PIOPutIOAPI2Client.h"

#import "PIOEpisodeListViewController.h"
#import "PIOVideoPlayerViewController.h"

#import "Show+PIOExtension.h"
#import "Episode+PIOExtensions.h"
#import "File.h"
#import "PutIOFile.h"
#import <KFData/KFDataTableViewDataSource.h>


@interface PIOEpisodeListViewController () <UIActionSheetDelegate>

@property (nonatomic, strong) Episode *selectedEpisode;

@end

@implementation PIOEpisodeListViewController

- (instancetype)initWithShow:(Show *)show {
    if (self = [super init]) {
        _show = show;
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                   target:self
                                                                                   action:@selector(close)];
    [[self navigationItem] setRightBarButtonItem:barButtonItem];

    Show *show = [self show];
    NSString *title = [show name];
    NSString *overview = [show overview];

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

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"show == %@ AND (file.@count > 0)", show];
    KFObjectManager *manager = [[Episode managerWithManagedObjectContext:[show managedObjectContext]] filter:predicate];
    [self setObjectManager:manager sectionNameKeyPath:@"season" cacheName:nil];
}

- (void)close {
    [[self navigationController] dismissViewControllerAnimated:YES completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForManagedObject:(Episode *)episode atIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }

    NSString *title = [episode name];

    if (title) {
        title = [NSString stringWithFormat:@"%@ %@", [episode episode], title];
    } else if ([episode episode]) {
        title = [NSString stringWithFormat:@"Episode %@", [episode episode]];
    } else if ([episode aired]) {
        NSDate *aired = [episode aired];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        title = [formatter stringFromDate:aired];
    }

    [[cell textLabel] setText:title];

    BOOL isWatched = [[episode watched] boolValue];
    [cell setAccessoryType:(isWatched ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone)];

    return cell;
}

#pragma mark -

#pragma message("TODO")
//- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    NSArray *sections = [[self dataSource] ];
//    id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
//
//    NSString *title = [NSString stringWithFormat:@"Season %@", [sectionInfo name]];
//    return title;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Episode *episode = (Episode*)[[self dataSource] objectAtIndexPath:indexPath];

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

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Episode *episode = (Episode*)[[self dataSource] objectAtIndexPath:indexPath];

        [[[self show] managedObjectContext] performWriteBlock:^ (NSManagedObjectContext *managedObjectContext) {
            NSSet *files = [[episode file] copy];

            for (File *file in files) {
                if ([file isKindOfClass:[PutIOFile class]]) {
                    [[PIOAppDelegate sharedPutIOAPIClient] deleteFile:(PutIOFile *)file];
                }

                [managedObjectContext deleteObject:file];
            }

            NSFetchRequest *fetchRequest = [[self dataSource] fetchRequest];
            KFObjectManager *manager = [KFObjectManager managerWithManagedObjectContext:managedObjectContext fetchRequest:fetchRequest];

            NSError *error;
            NSUInteger count = [manager count:&error];

            if (error == nil && count == 0) {
                [self close];
            }
        } success:nil failure:nil];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"EPISODE_LIST_DELETE_EPISODE_TITLE", nil);
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
