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
#define kPIOMediaCellSize CGSizeMake(116, 200)
#define kPIOMediaListSectionInset UIEdgeInsetsMake(30, 30, 30, 30)

@interface PIOMediaListViewController ()

@end

typedef enum {
    PIOMediaListShowType = 0,
    PIOMediaListFileType
} PIOMediaListTypes;

@implementation PIOMediaListViewController

- (id)initWithDataStore:(KFDataStore*)dataStore {
    UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    [collectionViewLayout setItemSize:kPIOMediaCellSize];
    [collectionViewLayout setSectionInset:kPIOMediaListSectionInset];

    if (self = [super initWithDataStore:dataStore
                   collectionViewLayout:collectionViewLayout]) {
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[self collectionView] registerNib:[UINib nibWithNibName:kPIOMediaCell bundle:nil]
            forCellWithReuseIdentifier:kPIOMediaCell];

    UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                  target:self
                                                                                  action:@selector(reloadData)];
    [[self navigationItem] setRightBarButtonItem:reloadButton];

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
}

- (void)reloadData {
    [[PIOAppDelegate sharedPutIOAPIClient] getFiles];
}

- (void)changeListType:(UISegmentedControl*)segmentedControl {
    [self setListType:[segmentedControl selectedSegmentIndex]];
}

- (void)setListType:(PIOMediaListTypes)listType {
    NSFetchRequest *fetchRequest;

    switch (listType) {
        case PIOMediaListShowType: {
            fetchRequest = [Show fetchRequestInManagedObjectContext:[self managedObjectContext]];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"episodes.@count > 0"]];
            [fetchRequest setSortDescriptors:@[
                [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES],
            ]];
            break;
        }

        case PIOMediaListFileType: {
            fetchRequest = [File fetchRequestInManagedObjectContext:[self managedObjectContext]];
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

        name = [(Show*)managedObject name];
        NSURL *posterURL = [NSURL URLWithString:[show poster]];
        [[cell posterImageView] setImageWithURL:posterURL];
    } else {
        name = [(File*)managedObject filename];
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
        [[self navigationController] pushViewController:episodesListViewController animated:YES];
    } else if ([managedObject isKindOfClass:[File class]]) {
        File *file = (File*)managedObject;

        PIOVideoPlayerViewController *playerViewController = [[PIOVideoPlayerViewController alloc] initWithFile:file];
        [self presentMoviePlayerViewControllerAnimated:playerViewController];
    }
}

@end
