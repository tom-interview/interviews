//
//  State.h
//  instaMe
//
//  Created by Tom Broadbent on 11/18/16.
//  Copyright © 2016 Tom Broadbent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface State : NSObject
+ (instancetype)sharedInstance;

- (NSString *)accessToken;
- (void)setAccessToken:(NSString *)accessToken;

- (NSString *)apiKey;
- (void)setApiKey:(NSString *)apiKey;

@end
