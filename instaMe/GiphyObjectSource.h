//
//  GiphyObjectSource.h
//  instaMe
//
//  Created by interview on 3/17/20.
//  Copyright © 2020 Tom Broadbent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"
#import "GiphyDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MediaObjectSource <NSObject>

- (id<MediaDataSource>)mediaDataSource;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithMediaDataSource:(id<MediaDataSource>)mediaDataSource;

- (NSURLSessionDataTask *)requestTrendingMediaWithSuccess:(void(^)(NSArray<id<MediaObject>> *))success failure:(void(^)(NSError *))failure;
- (NSURLSessionDataTask *)requestSearchMediaWithSuccess:(void(^)(NSArray<id<MediaObject>> *))success failure:(void(^)(NSError *))failure;

@end
@interface GiphyObjectSource : NSObject<MediaObjectSource>
@end

NS_ASSUME_NONNULL_END
