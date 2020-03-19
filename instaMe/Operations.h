//
//  Operations.h
//  instaMe
//
//  Created by interview on 3/17/20.
//  Copyright © 2020 Tom Broadbent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"
#import "Transceiver.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MediaObjectSource <NSObject>

- (id<MediaDataSource>)mediaDataSource;

- (NSURLSessionDataTask *)requestRecentMediaWithSuccess:(void(^)(NSArray<id<MediaObject>> *))success failure:(void(^)(NSError *))failure;
- (NSURLSessionDataTask *)requestNearbyMediaWithSuccess:(void(^)(NSArray<id<MediaObject>> *))success failure:(void(^)(NSError *))failure;
- (NSURLSessionDataTask *)requestMediaById:(MediaId *)mediaId success:(void(^)(id<MediaObject>))success failure:(void(^)(NSError *))failure;

@end
@interface Operations : NSObject<MediaObjectSource>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithMediaDataSource:(id<MediaDataSource>)mediaDataSource;

@end

NS_ASSUME_NONNULL_END
