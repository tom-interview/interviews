//
//  Operations.m
//  instaMe
//
//  Created by interview on 3/17/20.
//  Copyright © 2020 Tom Broadbent. All rights reserved.
//

#import "Operations.h"
#import "Transceiver.h"
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

#pragma mark - Operations
@interface Operations()
@property (strong, nonatomic) id<MediaDataSource> mediaSource;
@end

@implementation Operations

- (instancetype)initWithMediaSource:(id<MediaDataSource>)mediaSource
{
    if ((self = [super init])){
        [self setMediaSource:mediaSource];
    }
    return self;
}

- (id<MediaDataSource>)mediaSource
{
    return _mediaSource;
}

- (NSURLSessionDataTask *)requestRecentMediaWithSuccess:(void(^)(NSArray<id<MediaObject>> *))success failure:(void(^)(NSError *))failure { // FIXME pass a block to collapse common code (see below)
    return [self.mediaSource retrieveMediaTrendingWithSuccess:^(NSString * _Nullable jsonString) {
        [self handleMediaListResponseJsonString:jsonString success:success failure:failure];
    } failure:failure];
}

- (NSURLSessionDataTask *)requestNearbyMediaWithSuccess:(void(^)(NSArray<id<MediaObject>> *))success failure:(void(^)(NSError *))failure {
    // FIXME allow user to pass tag
    NSString *query = @"coronavirus";
    return [self.mediaSource retrieveMediaWithQuery:query success:^(NSString * _Nullable jsonString) {
        [self handleMediaListResponseJsonString:jsonString success:success failure:failure];
    } failure:failure];
}
- (NSURLSessionDataTask *)requestMediaById:(MediaId *)mediaId success:(void (^)(id<MediaObject>))success failure:(void (^)(NSError *))failure {
    return [self.mediaSource retrieveMediaById:mediaId success:^(NSString * _Nullable jsonString) {
        [self handleMediaItemResponseJsonString:jsonString success:success failure:failure];
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
