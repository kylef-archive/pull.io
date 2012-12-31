//
//  PIOVideoPlayerViewController.h
//  pull.io
//
//  Created by Kyle Fuller on 31/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

@class File;
@class Video;

@interface PIOVideoPlayerViewController : MPMoviePlayerViewController

@property (nonatomic, strong, readonly) Video *video;
@property (nonatomic, assign) BOOL resumeFromPreviousPlayback;

- (id)initWithVideo:(Video*)video;
- (id)initWithFile:(File*)file;

@end
