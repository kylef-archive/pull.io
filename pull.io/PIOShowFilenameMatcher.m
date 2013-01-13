//
//  PIOShowFilenameMatcher.m
//  pull.io
//
//  Created by Kyle Fuller on 16/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import "PIOShowFilenameMatcher.h"

@implementation PIOShowFilenameMatch

- (NSString*)description {
    return [NSString stringWithFormat:@"%@ S%@E%@", [self seriesName], [self seasonNumber], [self episodeNumbers]];
}

@end

@interface PIOShowFilenameMatcher ()

@property (nonatomic, strong) NSRegularExpression *standardShowExpression;
@property (nonatomic, strong) NSRegularExpression *fovShowExpression;

@end

@implementation PIOShowFilenameMatcher

#define kPIOStandardRegex @"^(?:(.+)[. _-]+)"   \
                          @"s(?:(\\d+)[. _-]*)" \
                          @"e(?:(\\d+)[. _-]*)" \
                          @"(.*)$"

#define kPIOFOVRegex @"^(?:(.+)[. _-]+)"   \
                     @"(?:(\\d+)[. _-]*)x" \
                     @"(?:(\\d+)[. _-]*)" \
                     @"(.*)$"


- (NSRegularExpression *)standardShowExpression {
    if (_standardShowExpression == nil) {
        NSError *error;
        _standardShowExpression = [NSRegularExpression regularExpressionWithPattern:kPIOStandardRegex
                                                                                    options:NSRegularExpressionCaseInsensitive
                                                                                      error:&error];

        if (_standardShowExpression == nil) {
            NSLog(@"Regex failed %@", error);
        }
    }

    return _standardShowExpression;
}

- (NSRegularExpression *)fovShowExpression {
    if (_fovShowExpression == nil) {
        NSError *error;
        _fovShowExpression = [NSRegularExpression regularExpressionWithPattern:kPIOFOVRegex
                                                                            options:NSRegularExpressionCaseInsensitive
                                                                              error:&error];
        
        if (_standardShowExpression == nil) {
            NSLog(@"Regex failed %@", error);
        }
    }
    
    return _fovShowExpression;
}

- (NSString*)cleanSeriesName:(NSString*)seriesName {
    /* Cleans up series name by removing any . and _
       characters, along with any trailing hyphens.

       Is basically equivalent to replacing all _ and . with a
       space, but handles decimal numbers in string.
    */

    NSMutableString *mutableSeriesName = [seriesName mutableCopy];

    NSRegularExpression *seriesNameEx = [[NSRegularExpression alloc] initWithPattern:@"(\\D)\\.(?!\\s)(\\D)"
                                                                             options:0
                                                                               error:nil];
    [seriesNameEx replaceMatchesInString:mutableSeriesName
                                 options:0
                                   range:NSMakeRange(0, [mutableSeriesName length])
                            withTemplate:@"$1 $2"];

    // if it ends in a year then don't keep the dot
    seriesNameEx = [[NSRegularExpression alloc] initWithPattern:@"(\\d)\\.(\\d{4})"
                                                        options:0
                                                          error:nil];
    [seriesNameEx replaceMatchesInString:mutableSeriesName
                                 options:0
                                   range:NSMakeRange(0, [mutableSeriesName length])
                            withTemplate:@"$1 $2"];

    seriesNameEx = [[NSRegularExpression alloc] initWithPattern:@"(\\D)\\.(?!\\s)"
                                                        options:0
                                                          error:nil];
    [seriesNameEx replaceMatchesInString:mutableSeriesName
                                 options:0
                                   range:NSMakeRange(0, [mutableSeriesName length])
                            withTemplate:@"$1 "];

    seriesNameEx = [[NSRegularExpression alloc] initWithPattern:@"\\.(?!\\s)(\\D)"
                                                        options:0
                                                          error:nil];
    [seriesNameEx replaceMatchesInString:mutableSeriesName
                                 options:0
                                   range:NSMakeRange(0, [mutableSeriesName length])
                            withTemplate:@" $1"];

    seriesName = [mutableSeriesName stringByReplacingOccurrencesOfString:@"_" withString:@" "];

    if ([mutableSeriesName hasSuffix:@"-"]) {
        seriesName = [mutableSeriesName substringToIndex:([mutableSeriesName length] - 1)];
    }

    seriesName = [seriesName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    return seriesName;
}

- (PIOShowFilenameMatch *)standardFilenameMatch:(NSString*)filename {
    NSRegularExpression *expression = [self standardShowExpression];

    NSTextCheckingResult *match = [expression firstMatchInString:filename
                                                         options:0
                                                           range:NSMakeRange(0, [filename length])];

    PIOShowFilenameMatch *result;

    if (match) {
        NSRange shownameRange = [match rangeAtIndex:1];
        NSRange seasonRange = [match rangeAtIndex:2];
        NSRange episodeRange = [match rangeAtIndex:3];

        result = [PIOShowFilenameMatch new];

        NSString *seriesName = [filename substringWithRange:shownameRange];
        seriesName = [self cleanSeriesName:seriesName];
        [result setSeriesName:seriesName];

        NSString *season = [filename substringWithRange:seasonRange];
        [result setSeasonNumber:[NSNumber numberWithInteger:[season integerValue]]];

        NSString *episode = [filename substringWithRange:episodeRange];
        [result setEpisodeNumbers:@[[NSNumber numberWithInteger:[episode integerValue]]]];
    }

    return result;
}

- (PIOShowFilenameMatch *)fovFilenameMatch:(NSString*)filename {
    NSRegularExpression *expression = [self fovShowExpression];

    NSTextCheckingResult *match = [expression firstMatchInString:filename
                                                         options:0
                                                           range:NSMakeRange(0, [filename length])];

    PIOShowFilenameMatch *result;

    if (match) {
        NSRange shownameRange = [match rangeAtIndex:1];
        NSRange seasonRange = [match rangeAtIndex:2];
        NSRange episodeRange = [match rangeAtIndex:3];

        result = [PIOShowFilenameMatch new];

        NSString *seriesName = [filename substringWithRange:shownameRange];
        seriesName = [self cleanSeriesName:seriesName];
        [result setSeriesName:seriesName];

        NSString *season = [filename substringWithRange:seasonRange];
        [result setSeasonNumber:[NSNumber numberWithInteger:[season integerValue]]];

        NSString *episode = [filename substringWithRange:episodeRange];
        [result setEpisodeNumbers:@[[NSNumber numberWithInteger:[episode integerValue]]]];
    }
    
    return result;
}

- (PIOShowFilenameMatch*)matchFilename:(NSString*)filename {
    PIOShowFilenameMatch *result = [self standardFilenameMatch:filename];

    if (result == nil) {
        result = [self fovFilenameMatch:filename];
    }

    return result;
}

@end
