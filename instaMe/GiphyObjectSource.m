//
//  GiphyObjectSource.m
//  instaMe
//
//  Created by interview on 3/17/20.
//  Copyright © 2020 Tom Broadbent. All rights reserved.
//

#import "GiphyObjectSource.h"
#import "GiphyDataSource.h"
#import "Model.h"
#import <JSONModel/JSONModel.h>

@protocol ImageMediaObject;
@protocol MediaResponse <NSObject>
@end


@interface MediaListResponse : JSONModel <MediaResponse>
@property (nonatomic) NSArray <ImageMediaObject> *data; // FIXME will need to parse this manually if list is heterogeneous
@end

@implementation MediaListResponse
@end


@interface MediaItemResponse : JSONModel <MediaResponse>
@property (nonatomic) ImageMediaObject *data; // FIXME will need to parse this manually to consider image vs video
@end

@implementation MediaItemResponse
@end


@interface GiphyObjectSource()
@property (strong, nonatomic) id<MediaDataSource> mediaDataSource;
@end

@implementation GiphyObjectSource

- (instancetype)initWithMediaDataSource:(id<MediaDataSource>)mediaDataSource
{
    if ((self = [super init])){
        [self setMediaDataSource:mediaDataSource];
    }
    return self;
}

- (id<MediaDataSource>)mediaDataSource
{
    return _mediaDataSource;
}

- (NSURLSessionDataTask *)requestTrendingMediaWithSuccess:(void(^)(NSArray<id<MediaObject>> *))success failure:(void(^)(NSError *))failure { // FIXME pass a block to collapse common code (see below)
    return [self.mediaDataSource retrieveMediaTrendingWithSuccess:^(NSString * _Nullable jsonString) {
        [self handleMediaListResponseJsonString:jsonString success:success failure:failure];
    } failure:failure];
}

- (NSURLSessionDataTask *)requestSearchMediaWithSuccess:(void(^)(NSArray<id<MediaObject>> *))success failure:(void(^)(NSError *))failure {
    // FIXME allow user to pass tag
    NSString *query = @"coronavirus";
    return [self.mediaDataSource retrieveMediaWithQuery:query success:^(NSString * _Nullable jsonString) {
        [self handleMediaListResponseJsonString:jsonString success:success failure:failure];
    } failure:failure];
}
- (void)handleMediaListResponseJsonString:(NSString *)jsonString success:(void(^)(NSArray<id<MediaObject>> *))success failure:(void(^)(NSError *))failure {
    MediaListResponse *mediaResponse;
    if ([(mediaResponse = (MediaListResponse *)[self parseMediaResponseJsonString:jsonString mediaResponseType:[MediaListResponse class] failure:failure]) isKindOfClass:[MediaListResponse class]]) {
        if (success) success(mediaResponse.data);
    }
    return;
}
- (void)handleMediaItemResponseJsonString:(NSString *)jsonString success:(void(^)(id<MediaObject>))success failure:(void(^)(NSError *))failure {
    MediaItemResponse *mediaResponse;
    if ([(mediaResponse = (MediaItemResponse *)[self parseMediaResponseJsonString:jsonString mediaResponseType:[MediaItemResponse class] failure:failure]) isKindOfClass:[MediaItemResponse class]]) {
        if (success) success(mediaResponse.data);
    }
}
- (id<MediaResponse>)parseMediaResponseJsonString:(NSString *)jsonString mediaResponseType:(Class)mediaResponseType failure:(void(^)(NSError *))failure {
    NSError *error;
    id<MediaResponse> mediaResponse = [[mediaResponseType alloc] initWithString:jsonString error:&error];
    if (error) {
        NSLog(@"unable to parse media response due to error: %@\n%@", error, jsonString);
        if (failure) failure(error);
        return nil;
    }

    return mediaResponse;
}

@end
