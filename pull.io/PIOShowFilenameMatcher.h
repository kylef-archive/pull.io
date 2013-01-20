//
//  PIOShowFilenameMatcher.h
//  pull.io
//
//  Created by Kyle Fuller on 16/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PIOShowFilenameMatch : NSObject

@property (nonatomic, strong) NSString *seriesName;
@property (nonatomic, strong) NSNumber *seasonNumber;

@property (nonatomic, strong) NSArray *episodeNumbers;

@property (nonatomic, strong) NSDate *aired;

@end

@interface PIOShowFilenameMatcher : NSObject

- (NSString*)cleanSeriesName:(NSString*)seriesName;
- (PIOShowFilenameMatch*)matchFilename:(NSString*)filename;

@end
