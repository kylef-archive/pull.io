//
//  PIOEpisodeListViewController.h
//  pull.io
//
//  Created by Kyle Fuller on 16/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import <KFDataTableViewController.h>

@class Show;

@interface PIOEpisodeListViewController : KFDataTableViewController

@property (nonatomic, strong, readonly) Show *show;

- (instancetype)initWithShow:(Show *)show;

@end
