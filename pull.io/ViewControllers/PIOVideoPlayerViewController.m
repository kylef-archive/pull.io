//
//  PIOVideoPlayerViewController.m
//  pull.io
//
//  Created by Kyle Fuller on 31/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import "NSManagedObjectContext+KFData.h"
#import "Video.h"
#import "File.h"

#import "PIOVideoPlayerViewController.h"

@interface PIOVideoPlayerViewController ()

@end

@implementation PIOVideoPlayerViewController

- (id)initWithVideo:(Video*)video {
    File *file = (File*)[[video file] anyObject];

    if (self = [self initWithFile:file]) {
        _video = video;
        _resumeFromPreviousPlayback = NO;
    }

    return self;
}

- (id)initWithFile:(File*)file {
    NSURL *URL = [file URL];
    
    if (self = [super initWithContentURL:URL]) {
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    MPMoviePlayerController *moviePlayer = [self moviePlayer];
    [moviePlayer setMovieSourceType:MPMovieSourceTypeStreaming];

    Video *video = [self video];
    if (video) {
        if ([self resumeFromPreviousPlayback]) {
            NSTimeInterval timestamp = [[video playback_time] doubleValue];
            [moviePlayer setInitialPlaybackTime:timestamp];
        }

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateState)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:moviePlayer];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateState)
                                                     name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                   object:moviePlayer];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    if ([event subtype] == UIEventSubtypeRemoteControlTogglePlayPause) {
        MPMoviePlayerController *moviePlayer = [self moviePlayer];

        if ([moviePlayer playbackState] == MPMusicPlaybackStatePlaying) {
            [moviePlayer pause];
        } else {
            [moviePlayer play];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)updateState {
    NSTimeInterval duration = [[self moviePlayer] duration];
    NSTimeInterval currentPlaybackTime = [[self moviePlayer] currentPlaybackTime];

    Video *video = [self video];

    [[video managedObjectContext] performWriteBlock:^{
        [video setPlayback_time:[NSNumber numberWithDouble:currentPlaybackTime]];

        if (([[video watched] boolValue] == NO) &&
            duration &&
            (currentPlaybackTime >= (duration - 60.0)))
        {
            [video setWatched:@YES];
        }
    }];
}

@end
