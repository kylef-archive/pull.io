//
//  PIOShowFilenameMatcher.m
//  pull.io
//
//  Created by Kyle Fuller on 16/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import "PIOShowFilenameMatcherTests.h"
#import "PIOShowFilenameMatcher.h"

@interface PIOShowFilenameMatcherTests ()

@property (nonatomic, strong) PIOShowFilenameMatcher *filenameMatcher;

@end

@implementation PIOShowFilenameMatcherTests

- (void)setUp {
    PIOShowFilenameMatcher *filenameMatcher = [[PIOShowFilenameMatcher alloc] init];
    [self setFilenameMatcher:filenameMatcher];
}

#define PIOAssertCleanSeries(A, B) STAssertEqualObjects([filenameMatcher cleanSeriesName:A], B, nil)

- (void)testCleanSeriesName {
    PIOShowFilenameMatcher *filenameMatcher = [self filenameMatcher];

    PIOAssertCleanSeries(@"an.example.1.0.test", @"an example 1.0 test");
    PIOAssertCleanSeries(@"an_example_1.0_test", @"an example 1.0 test");
    PIOAssertCleanSeries(@"Test-", @"Test");
    PIOAssertCleanSeries(@" Test -", @"Test");
    PIOAssertCleanSeries(@"-", @"");
}

#define PIOAssertShow(A, B, C, D) { \
        PIOShowFilenameMatch *result = [[self filenameMatcher] matchFilename:A]; \
        STAssertEqualObjects([result seriesName], B, nil); \
        STAssertEqualObjects([result seasonNumber], C, nil); \
        STAssertEqualObjects([result episodeNumbers], D, nil); \
    }

- (void)testStandardShow {
    // Tests taken from sickbeard https://github.com/midgetspy/Sick-Beard/blob/master/tests/name_parser_tests.py

    PIOAssertShow(@"Mr.Show.Name.S01E02.Source.Quality.Etc-Group", @"Mr Show Name", @1, @[@2]);
    PIOAssertShow(@"Show.Name.S01E02", @"Show Name", @1, @[@2]);
    PIOAssertShow(@"Show Name - S01E02 - My Ep Name", @"Show Name", @1, @[@2]);
    PIOAssertShow(@"Show.1.0.Name.S01.E03.My.Ep.Name-Group", @"Show 1.0 Name", @1, @[@3]);
    
//    PIOAssertShow(@"Show.Name.S01E02E03.Source.Quality.Etc-Group", @"Show Name", @1, @[@2, @3]);
//    PIOAssertShow(@"Mr. Show Name - S01E02-03 - My Ep Name", @"Mr. Show Name", @1, @[@2, @3]);
//    PIOAssertShow(@"Show.Name.S01.E02.E03", @"Show Name", @1, @[@2, @3]);
//    PIOAssertShow(@"Show.Name-0.2010.S01E02.Source.Quality.Etc-Group", @"Show Name", @1, @[@2]);

    PIOAssertShow(@"Show Name - S06E01 - 2009-12-20 - Ep Name", @"Show Name", @6, @[@1]);
    PIOAssertShow(@"Show Name - S06E01 - -30-", @"Show Name", @6, @[@1]);
    
//    PIOAssertShow(@"Show-Name-S06E01-720p", @"Show Name", @6, @[@1]);
//    PIOAssertShow(@"Show-Name-S06E01-1080i", @"Show Name", @6, @[@1]);
    PIOAssertShow(@"Show.Name.S06E01.Other.WEB-DL", @"Show Name", @6, @[@1]);
    PIOAssertShow(@"Show.Name.S06E01 Some-Stuff Here", @"Show Name", @6, @[@1]);
}

- (void)testFOVShow {
    PIOAssertShow(@"Show_Name.1x02.Source_Quality_Etc-Group", @"Show Name", @1, @[@2]);
    PIOAssertShow(@"Show Name 1x02", @"Show Name", @1, @[@2]);
    PIOAssertShow(@"Show Name 1x02 x264 Test", @"Show Name", @1, @[@2]);
    PIOAssertShow(@"Show Name - 1x02 - My Ep Name", @"Show Name", @1, @[@2]);

//    PIOAssertShow(@"Show_Name.1x02x03x04.Source_Quality_Etc-Group", @"Show Name", @1, @[@2, @3, @4]);
//    PIOAssertShow(@"Show Name - 1x02-03-04 - My Ep Name", @"Show Name", @1, @[@2, @3, @4]);
    PIOAssertShow(@"Show Name 1x02 x264 Test", @"Show Name", @1, @[@2]);
    PIOAssertShow(@"Show Name - 1x02 - My Ep Name", @"Show Name", @1, @[@2]);
}

@end
