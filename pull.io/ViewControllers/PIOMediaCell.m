//
//  PIOMediaCell.m
//  pull.io
//
//  Created by Kyle Fuller on 19/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import "UIImageView+AFNetworking.h"
#import "PIOMediaCell.h"

@implementation PIOMediaCell

- (void)prepareForReuse {
    [super prepareForReuse];

    [[self posterImageView] cancelImageRequestOperation];
}

@end
