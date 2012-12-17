//
//  PIOAppDelegate.m
//  pull.io
//
//  Created by Kyle Fuller on 01/12/2012.
//  Copyright (c) 2012 Kyle Fuller. All rights reserved.
//

#import "KFDataStore.h"
#import "PIOAppDelegate.h"
#import "PIOPutIOAPI2Client.h"
#import "PIOTraktAPIClient.h"

#import "PIOMediaListViewController.h"

#ifdef TESTFLIGHT
#import "TestFlight.h"
#endif

#import "PIOFileManager.h"

@interface PIOAppDelegate ()

@property (nonatomic, strong) KFDataStore *dataStore;
@property (nonatomic, strong) PIOPutIOAPI2Client *putIOAPIClient;
@property (nonatomic, strong) PIOTraktAPIClient *traktAPIClient;

@property (nonatomic, strong) PIOFileManager *fileManager;

@end

@implementation PIOAppDelegate

+ (PIOAppDelegate*)sharedAppDelegate {
    return (PIOAppDelegate*)[[UIApplication sharedApplication] delegate];
}

+ (KFDataStore*)sharedDataStore {
    KFDataStore *dataStore = [[self sharedAppDelegate] dataStore];
    return dataStore;
}

+ (PIOPutIOAPI2Client*)sharedPutIOAPIClient {
    PIOPutIOAPI2Client *client = [[self sharedAppDelegate] putIOAPIClient];
    return client;
}

+ (PIOTraktAPIClient*)sharedTraktAPIClient {
    PIOTraktAPIClient *client = [[self sharedAppDelegate] traktAPIClient];
    return client;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    KFDataStore *dataStore = [KFDataStore standardLocalDataStore];
    [self setDataStore:dataStore];

    NSManagedObjectContext *managedObjectContext = [dataStore managedObjectContextWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [self setPutIOAPIClient:[[PIOPutIOAPI2Client alloc] initWithManagedObjectContext:managedObjectContext]];

    managedObjectContext = [dataStore managedObjectContextWithConcurrencyType:NSPrivateQueueConcurrencyType];
    PIOFileManager *fileManager = [[PIOFileManager alloc] initWithManagedObjectContext:managedObjectContext];
    [self setFileManager:fileManager];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];

    PIOMediaListViewController *viewController = [[PIOMediaListViewController alloc] initWithDataStore:[self dataStore]];
    viewController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [[self window] setRootViewController:viewController];

    [self.window makeKeyAndVisible];

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[self putIOAPIClient] hasAuthorization]) {
            [[self putIOAPIClient] getFiles];
        } else {
            NSURL *URL = [[self putIOAPIClient] authenticationURL];
            [[UIApplication sharedApplication] openURL:URL];
        }
    });

#ifdef TESTFLIGHT
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    [TestFlight takeOff:@"90318dae391050c32c29073903490170_OTg2OTEyMDEyLTA2LTEwIDE0OjI1OjU1LjYyNzM2Ng"];
#endif

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    BOOL result = NO;

    NSString *scheme = [url scheme];

    if ([scheme isEqualToString:@"pullio"]) {
        NSString *host = [url host];
        if ([host isEqualToString:@"oauth-callback.put.io"]) {
            NSString *path = [url path];
            // We should really parse the code
            NSString *code = [path substringFromIndex:7];

            [[self putIOAPIClient] authenticateUsingCode:code success:^(AFOAuthCredential *credential) {
                NSLog(@"Authentication success: %@", credential);
            } failure:^(NSError *error) {
                NSLog(@"Authentication failure: %@", error);
            }];

            result = YES;
        }
    }

    return result;
}

@end
