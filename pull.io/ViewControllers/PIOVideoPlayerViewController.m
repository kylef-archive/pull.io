//
//  PIOVideoPlayerViewController.m
//  pull.io
//
//  Created by Kyle Fuller on 31/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import "NSManagedObjectContext+KFData.h"
#import "File.h"
#import "Video.h"

#import "PIOVideoPlayerViewController.h"

@interface PIOVideoPlayerViewController ()

@end

@implementation PIOVideoPlayerViewController

- (id)initWithFile:(File*)file {
    NSURL *URL = [file URL];

    if (self = [super initWithContentURL:URL]) {
        _file = file;
    }

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    MPMoviePlayerController *moviePlayer = [self moviePlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateState)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateState)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:moviePlayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)updateState {
    NSTimeInterval duration = [[self moviePlayer] duration];
    NSTimeInterval currentPlaybackTime = [[self moviePlayer] currentPlaybackTime];

    File *file = [self file];
    [[file managedObjectContext] performWriteBlock:^{
        Video *video = [file video];

        [video setPlayback_time:[NSNumber numberWithDouble:currentPlaybackTime]];

        if (([[video watched] boolValue] == NO) &&
            duration &&
            (currentPlaybackTime >= duration))
        {
            [video setWatched:@YES];
        }
    }];
}

@end
