//
//  NSString+PIOExtensions.m
//  pull.io
//
//  Created by Kyle Fuller on 31/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import "NSString+PIOExtensions.h"

@implementation NSString (PIOExtensions)

+ (NSString *)stringWithTimeInterval:(NSTimeInterval)interval {
    NSInteger time = (NSInteger)interval;
    NSInteger seconds = time % 60;
    NSInteger minutes = (time / 60) % 60;
    NSInteger hours = (time / 3600);

    NSString *string;

    if (hours > 0) {
        string = [NSString stringWithFormat:@"%02i:%02i:%02i", hours, minutes, seconds];
    } else {
        string = [NSString stringWithFormat:@"%02i:%02i", minutes, seconds];
    }

    return string;
}

@end
