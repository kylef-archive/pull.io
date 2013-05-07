//
//  PIOMediaCell.h
//  pull.io
//
//  Created by Kyle Fuller on 19/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PIOMediaCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *posterImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@property (nonatomic, weak) IBOutlet UIView *banner;

@end
