//
//  AppDelegate.m
//  instaMe
//
//  Created by Tom Broadbent on 11/17/16.
//  Copyright © 2016 Tom Broadbent. All rights reserved.
//

#import "AppDelegate.h"
#import "GiphyDataSource.h"
#import "GiphyObjectSource.h"
#import "ImageCollectionController.h"

@interface AppDelegate ()
@property (strong, nonatomic) id<MediaObjectSource> source;
@end

@implementation AppDelegate

- (id<MediaObjectSource>)mediaObjectSource
{
    return self.source;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    id<MediaDataSource> ms = [[GiphyDataSource alloc] init];
    [(GiphyDataSource *)ms setKey:@"hPZGRXFTxALgeadQwSTUIZ0oNRcLmrXB"];
    [self setSource:(id<MediaObjectSource>)[[GiphyObjectSource alloc] initWithMediaDataSource:ms]];
    
    [self customizeAppearance];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)customizeAppearance {
    [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithWhite:.4 alpha:1]];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithWhite:.4 alpha:1]];
}
@end
