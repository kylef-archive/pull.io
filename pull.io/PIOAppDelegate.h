//
//  PIOAppDelegate.h
//  pull.io
//
//  Created by Kyle Fuller on 01/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KFDataStore;
@class PIOPutIOAPI2Client;

@interface PIOAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (KFDataStore*)sharedDataStore;
+ (PIOPutIOAPI2Client*)sharedPutIOAPIClient;

@end
