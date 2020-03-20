//
//  AppDelegate.h
//  instaMe
//
//  Created by Tom Broadbent on 11/17/16.
//  Copyright © 2016 Tom Broadbent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GiphyObjectSource.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
- (id<MediaObjectSource>)mediaObjectSource;

@end

