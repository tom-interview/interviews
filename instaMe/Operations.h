//
//  Operations.h
//  instaMe
//
//  Created by interview on 3/17/20.
//  Copyright © 2020 Tom Broadbent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"

NS_ASSUME_NONNULL_BEGIN

@interface Operations : NSObject
+ (instancetype)sharedInstance;

- (NSURLSessionDataTask *)requestRecentMediaWithSuccess:(void(^)(NSArray<id<MediaObject>> *))success failure:(void(^)(NSError *))failure;
- (NSURLSessionDataTask *)requestNearbyMediaWithSuccess:(void(^)(NSArray<id<MediaObject>> *))success failure:(void(^)(NSError *))failure;
- (NSURLSessionDataTask *)requestMediaById:(MediaId *)mediaId success:(void(^)(id<MediaObject>))success failure:(void(^)(NSError *))failure;

@end

NS_ASSUME_NONNULL_END
