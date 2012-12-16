//
//  PIOMediaListViewController.m
//  pull.io
//
//  Created by Kyle Fuller on 16/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import "NSManagedObject+KFData.h"
#import "PIOMediaListViewController.h"
#import "PIOEpisodeListViewController.h"
#import "Show.h"

@interface PIOMediaListViewController ()

@end

@implementation PIOMediaListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:NSLocalizedString(@"SHOW_LIST_TITLE", nil)];

    NSFetchRequest *fetchRequest = [Show fetchRequestInManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setSortDescriptors:@[
       [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES],
    ]];

    [self setFetchRequest:fetchRequest sectionNameKeyPath:nil];
}

#pragma mark -

- (NSString*)fetchedResultsTableController:(KFFetchedResultsTableController *)fetchedResultsTableController
           reuseIdentifierForManagedObject:(NSManagedObject *)managedObject
                               atIndexPath:(NSIndexPath *)indexPath
{
    return @"cell";
}

- (void)fetchedResultsTableController:(KFFetchedResultsTableController *)fetchedResultsTableController
                       configuredCell:(UITableViewCell *)cell
                     forManagedObject:(NSManagedObject *)managedObject
                          atIndexPath:(NSIndexPath *)indexPath
{
    [[cell textLabel] setText:[managedObject valueForKey:@"name"]];
}

- (UITableViewCell*)fetchedResultsTableController:(KFFetchedResultsTableController *)fetchedResultsTableController
                           cellForReuseIdentifier:(NSString *)reuseIdentifier
{
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
}

#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *managedObject = [[self fetchedResultsTableController] managedObjectForIndexPath:indexPath];

    PIOEpisodeListViewController *episodesListViewController = [[PIOEpisodeListViewController alloc] initWithManagedObjectContext:[self managedObjectContext]];
    [episodesListViewController setShow:[managedObject objectID]];
    [[self navigationController] pushViewController:episodesListViewController animated:YES];
}

@end
