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

@end

@implementation UserId
@end
@implementation MediaId
@end


@interface User()
@property (nonatomic) NSInteger id;
@end

@implementation User
@end


@interface ImageMediaObject()
@property (nonatomic) NSInteger id;
@end

@implementation ImageMediaObject

+ (JSONKeyMapper *)keyMapper
{
    NSDictionary *keyMap = @{
                             @"thumbnailImage": @"images.thumbnail",
                             @"standardImage": @"images.low_resolution",
                             };
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:keyMap];
}
@end


@implementation ImageObject
@end


@protocol ImageMediaObject;

@interface MediaResponse : JSONModel

@property (nonatomic) NSArray <ImageMediaObject> *data; // FIXME will need to parse this manually if list is heterogeneous

@end

@implementation MediaResponse
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
    return [[Transceiver sharedInstance] retrieveMediaForAuthenticatedUserWithSuccess:^(NSString * _Nullable jsonString) {
        NSError *error;
        MediaResponse *mediaResponse = [[MediaResponse alloc] initWithString:jsonString error:&error];
        if (error) {
            NSLog(@"unable to parse media response due to error: %@\n%@", error, jsonString);
            if (failure) failure(error);
            return;
        }

        if (success) success(mediaResponse.data);
        return;

    } failure:^(NSError * _Nullable error) {
        if (failure) failure(error);
        return;
    }];
}

- (NSURLSessionDataTask *)requestNearbyMediaWithSuccess:(void(^)(NSArray<id<MediaObject>> *))success failure:(void(^)(NSError *))failure {
    // FIXME get user location via CoreLocation
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(38.6717358, -121.1573656); // Trader Joe's

    return [[Transceiver sharedInstance] retrieveMediaNearLocationCoordinate:coordinate success:^(NSString * _Nullable jsonString) {
        NSError *error;
        MediaResponse *mediaResponse = [[MediaResponse alloc] initWithString:jsonString error:&error];
        if (error) {
            NSLog(@"unable to parse media response due to error: %@\n%@", error, jsonString);
            if (failure) failure(error);
            return;
        }

        if (success) success(mediaResponse.data);
        return;

    } failure:^(NSError * _Nullable error) {
        if (failure) failure(error);
        return;
    }];
}

@end
