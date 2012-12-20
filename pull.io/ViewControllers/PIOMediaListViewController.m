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
#import "PIOEpisodeListViewController.h"
#import "Show.h"
#import "PIOMediaCell.h"

#define kPIOMediaCell @"PIOMediaCell"
#define kPIOMediaCellSize CGSizeMake(116, 200)
#define kPIOMediaListSectionInset UIEdgeInsetsMake(30, 30, 30, 30)

@interface PIOMediaListViewController ()

@end

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

    [self setTitle:NSLocalizedString(@"SHOW_LIST_TITLE", nil)];

    NSFetchRequest *fetchRequest = [Show fetchRequestInManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setSortDescriptors:@[
       [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES],
    ]];

    [self setFetchRequest:fetchRequest sectionNameKeyPath:nil];

    [[self collectionView] registerNib:[UINib nibWithNibName:kPIOMediaCell bundle:nil]
            forCellWithReuseIdentifier:kPIOMediaCell];

    UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                  target:self
                                                                                  action:@selector(reloadData)];
    [[self navigationItem] setRightBarButtonItem:reloadButton];
}

- (void)reloadData {
    [[PIOAppDelegate sharedPutIOAPIClient] getFiles];
}

#pragma mark -

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PIOMediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPIOMediaCell
                                                                           forIndexPath:indexPath];

    Show *show = [[self fetchedResultsController] objectAtIndexPath:indexPath];

    [[cell titleLabel] setText:[show name]];
    NSURL *posterURL = [NSURL URLWithString:[show poster]];
    [[cell posterImageView] setImageWithURL:posterURL];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *managedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];

    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [managedObjectContext setParentContext:[self managedObjectContext]];
    PIOEpisodeListViewController *episodesListViewController = [[PIOEpisodeListViewController alloc] initWithManagedObjectContext:managedObjectContext];
    [episodesListViewController setShow:[managedObject objectID]];
    [[self navigationController] pushViewController:episodesListViewController animated:YES];
}

@end
