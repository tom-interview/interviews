//
//  Model.m
//  instaMe
//
//  Created by Tom Broadbent on 11/17/16.
//  Copyright © 2016 Tom Broadbent. All rights reserved.
//

#import "Model.h"
#import "Transceiver.h"

@implementation _Id

- (instancetype)initWithId:(NSString *)id {
    if ((self = [super init])) {
        _objectId = id;
    }
    return self;
}
+ (instancetype)idWithId:(NSString *)id {
    return [[self alloc] initWithId:id];
}

- (BOOL)isEqual:(id)other {
    if (self == other) {
        return YES;
    }

    return [self isEqualToId:other];
}
- (BOOL)isEqualToId:(_Id *)other {
    if (!other) {
        return NO;
    }
    if (![other isKindOfClass:[self class]]) {
        return NO;
    }

    return (self.objectId && [self.objectId isEqualToString:other.objectId]);
}

- (NSUInteger)hash {
    return [self.objectId hash];
}

@end

@implementation UserId
@end
@implementation MediaId
@end


@interface User()
@property (nonatomic) NSInteger id;
@end

@implementation User
- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err {
    if ((self = [super initWithDictionary:dict error:err])) {
        [self setUserId:[[UserId alloc] initWithId:[NSNumber numberWithInteger:_id].stringValue]];
    }
    return self;
}

+ (JSONKeyMapper *)keyMapper
{
    NSDictionary *keyMap = @{
                             @"fullname": @"full_name",
                             };
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:keyMap];
}
@end


@interface ImageMediaObject()
@property (nonatomic) NSInteger id;
@end

@implementation ImageMediaObject

- (BOOL)isLikedByUser {
    return false;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err {
    if ((self = [super initWithDictionary:dict error:err])) {
        [self setMediaId:[[MediaId alloc] initWithId:[NSNumber numberWithInteger:_id].stringValue]];
    }
    return self;
}

+ (JSONKeyMapper *)keyMapper
{
    NSDictionary *keyMap = @{
                             @"thumbnailImage": @"images.thumbnail",
                             @"standardImage": @"images.low_resolution",
                             @"likeCount": @"likes.count",
                             @"userHasLiked": @"user_has_liked",
                             };
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:keyMap];
}
@end


@implementation ImageObject
@end

@implementation ImagesObject
@end


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


@implementation Model

+ (instancetype)sharedInstance {
    static Model *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}
- (NSURLSessionDataTask *)requestRecentMediaWithSuccess:(void(^)(NSArray<id<MediaObject>> *))success failure:(void(^)(NSError *))failure { // FIXME pass a block to collapse common code (see below)
    return [[Transceiver sharedInstance] retrieveMediaTrendingWithSuccess:^(NSString * _Nullable jsonString) {
        [self handleMediaListResponseJsonString:jsonString success:success failure:failure];
    } failure:failure];
}

- (NSURLSessionDataTask *)requestNearbyMediaWithSuccess:(void(^)(NSArray<id<MediaObject>> *))success failure:(void(^)(NSError *))failure {
    // FIXME allow user to pass tag
    NSString *query = @"coronavirus";
    return [[Transceiver sharedInstance] retrieveMediaWithQuery:query success:^(NSString * _Nullable jsonString) {
        [self handleMediaListResponseJsonString:jsonString success:success failure:failure];
    } failure:failure];
}
- (NSURLSessionDataTask *)requestMediaById:(MediaId *)mediaId success:(void (^)(id<MediaObject>))success failure:(void (^)(NSError *))failure {
    return [[Transceiver sharedInstance] retrieveMediaById:mediaId success:^(NSString * _Nullable jsonString) {
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
