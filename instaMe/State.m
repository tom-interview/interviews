//
//  State.m
//  instaMe
//
//  Created by Tom Broadbent on 11/18/16.
//  Copyright © 2016 Tom Broadbent. All rights reserved.
//

#import "State.h"
#import <SAMKeychain/SAMKeychain.h>

@interface State()

- (NSString *)stringForKey:(NSString *)key;
- (void)setString:(NSString *)string forKey:(NSString *)key;

- (NSString *)secureStringForKey:(NSString *)key;
- (void)setSecureString:(NSString *)string forKey:(NSString *)key;

@end

@implementation State

- (NSString *)defaultService {
    return @"instaMe";
}

+ (instancetype)sharedInstance {
    static State *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

- (NSString *)stringForKey:(NSString *)key {
    @throw NSGenericException; // not implemented;
}
- (void)setString:(NSString *)string forKey:(NSString *)key {
    @throw NSGenericException; // not implemented;
}

- (NSString *)secureStringForKey:(NSString *)key {
    return [SAMKeychain passwordForService:[self defaultService] account:key];
}
- (void)setSecureString:(NSString *)string forKey:(NSString *)key {
    if ([string length]) {
        [SAMKeychain setPassword:string forService:[self defaultService] account:key]; // FIXME check for errors
    }
    else {
        [SAMKeychain deletePasswordForService:[self defaultService] account:key];
    }
}

static NSString *KEY_accessToken = @"accessToken";
- (NSString *)accessToken {
    return [self secureStringForKey:KEY_accessToken];
}
- (void)setAccessToken:(NSString *)accessToken {
    [self setSecureString:accessToken forKey:KEY_accessToken];
}

@end
