//
//  PIOMediaListViewController.m
//  pull.io
//
//  Created by Kyle Fuller on 16/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "PIOAppDelegate.h"
#import "PIOPutIOAPI2Client.h"

#import "NSManagedObject+KFData.h"
#import "PIOMediaListViewController.h"
#import "PIOVideoPlayerViewController.h"
#import "PIOEpisodeListViewController.h"
#import "Show.h"
#import "File.h"
#import "PIOMediaCell.h"

#define kPIOMediaCell @"PIOMediaCell"
#define kPIOMediaCellPad @"PIOMediaCell~ipad"
#define kPIOMediaCellSize CGSizeMake(121, 200)
#define kPIOMediaCellPadSize CGSizeMake(193, 300)
#define kPIOMediaListSectionInset UIEdgeInsetsMake(30, 30, 30, 30)
#define kPIOMediaListSectionPadInset UIEdgeInsetsMake(30, 50, 30, 50)

@interface PIOMediaListViewController ()

@property (nonatomic, weak) UIRefreshControl *refreshControl;

@end

typedef enum {
    PIOMediaListShowType = 0,
    PIOMediaListFileType
} PIOMediaListTypes;

@implementation PIOMediaListViewController

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [collectionViewLayout setItemSize:kPIOMediaCellPadSize];
        [collectionViewLayout setSectionInset:kPIOMediaListSectionPadInset];
    } else {
        [collectionViewLayout setItemSize:kPIOMediaCellSize];
        [collectionViewLayout setSectionInset:kPIOMediaListSectionInset];
    }

    if (self = [super initWithManagedObjectContext:managedObjectContext
                              collectionViewLayout:collectionViewLayout]) {
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[self collectionView] setBackgroundColor:[UIColor colorWithRed:0.118 green:0.133 blue:0.137 alpha:1]]; /*#1e2223*/

    UINib *cellNib;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        cellNib = [UINib nibWithNibName:kPIOMediaCellPad bundle:nil];
    } else {
        cellNib = [UINib nibWithNibName:kPIOMediaCell bundle:nil];
    }

    [[self collectionView] registerNib:cellNib
            forCellWithReuseIdentifier:kPIOMediaCell];

    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[
        NSLocalizedString(@"MEDIA_LIST_SHOWS_FILTER", nil),
        NSLocalizedString(@"MEDIA_LIST_FILES_FILTER", nil),
    ]];

    [segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [segmentedControl addTarget:self
                         action:@selector(changeListType:)
               forControlEvents:UIControlEventValueChanged];

    [[self navigationItem] setTitleView:segmentedControl];

    [segmentedControl setSelectedSegmentIndex:0];
    [self setListType:0];

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    [[self collectionView] addSubview:refreshControl];
    [[self collectionView] setAlwaysBounceVertical:YES];
    [self setRefreshControl:refreshControl];
}

- (void)reloadData {
    [[PIOAppDelegate sharedPutIOAPIClient] getFilesSuccess:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self refreshControl] endRefreshing];
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self refreshControl] endRefreshing];
        });
    }];
}

- (void)changeListType:(UISegmentedControl*)segmentedControl {
    [self setListType:[segmentedControl selectedSegmentIndex]];
}

- (void)setListType:(PIOMediaListTypes)listType {
    NSFetchRequest *fetchRequest;

    switch (listType) {
        case PIOMediaListShowType: {
            fetchRequest = [Show requestAllInManagedObjectContext:[self managedObjectContext]];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"SUBQUERY(episodes, $episode, SUBQUERY($episode.file, $file, $file != nil).@count > 0).@count > 0"]];
            [fetchRequest setSortDescriptors:@[
                [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES],
            ]];
            break;
        }

        case PIOMediaListFileType: {
            fetchRequest = [File requestAllInManagedObjectContext:[self managedObjectContext]];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"video == nil"]];
            [fetchRequest setSortDescriptors:@[
                [NSSortDescriptor sortDescriptorWithKey:@"filename" ascending:YES],
            ]];
            break;
        }
    }
    
    [self setFetchRequest:fetchRequest sectionNameKeyPath:nil];
}

#pragma mark -

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PIOMediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPIOMediaCell
                                                                           forIndexPath:indexPath];

    NSManagedObject *managedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];

    NSString *name;
    if ([managedObject isKindOfClass:[Show class]]) {
        Show *show = (Show*)managedObject;

        name = [show name];
        NSURL *posterURL = [NSURL URLWithString:[show poster]];
        [[cell posterImageView] setImageWithURL:posterURL];

        NSSet *episodes = [[show episodes] filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"watched == NO AND file.@count > 0"]];
        [[cell banner] setHidden:([episodes count] ? NO : YES)];
    } else {
        name = [(File*)managedObject filename];
        [[cell banner] setHidden:YES];
    }

    [[cell titleLabel] setText:name];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *managedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];

    if ([managedObject isKindOfClass:[Show class]]) {
        NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [managedObjectContext setParentContext:[self managedObjectContext]];
        PIOEpisodeListViewController *episodesListViewController = [[PIOEpisodeListViewController alloc] initWithManagedObjectContext:managedObjectContext];
        [episodesListViewController setShow:[managedObject objectID]];

        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:episodesListViewController];
        [navigationController setModalPresentationStyle:UIModalPresentationFormSheet];

        [self presentViewController:navigationController animated:YES completion:nil];
    } else if ([managedObject isKindOfClass:[File class]]) {
        File *file = (File*)managedObject;

        PIOVideoPlayerViewController *playerViewController = [[PIOVideoPlayerViewController alloc] initWithFile:file];
        [self presentMoviePlayerViewControllerAnimated:playerViewController];
    }
}

@end
