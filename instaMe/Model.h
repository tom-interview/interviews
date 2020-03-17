//
//  Model.h
//  instaMe
//
//  Created by Tom Broadbent on 11/17/16.
//  Copyright © 2016 Tom Broadbent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <JSONModel/JSONModel.h>

@interface _Id : NSObject
@property (strong, nonatomic) NSString *objectId;
- (instancetype)initWithId:(NSString *)id;
+ (instancetype)idWithId:(NSString *)id;
@end

@interface UserId : _Id
@end

@interface MediaId : _Id
@end

@protocol MediaObject <NSObject>
- (MediaId *)mediaId;
@end


@interface User : JSONModel
@property (nonatomic) UserId <Ignore> *userId;
@property (nonatomic) NSString *username;
@property (nonatomic) NSString *fullname;
@end


@interface ImageObject : JSONModel
@property (nonatomic) NSString *url;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@end

@interface ImagesObject : JSONModel
@property (nonatomic) ImageObject *downsized;
@property (nonatomic) ImageObject *original;
@end


@interface ImageMediaObject : JSONModel <MediaObject>
@property (nonatomic) MediaId <Ignore> *mediaId;
//@property (nonatomic) User *user;
//@property (nonatomic) NSInteger likeCount;
//@property (nonatomic) BOOL userHasLiked;
@property (nonatomic) NSString *title;
@property (nonatomic) ImagesObject *images;
@end


@interface Model : NSObject
+ (instancetype)sharedInstance;

- (NSURLSessionDataTask *)requestRecentMediaWithSuccess:(void(^)(NSArray<id<MediaObject>> *))success failure:(void(^)(NSError *))failure;
- (NSURLSessionDataTask *)requestNearbyMediaWithSuccess:(void(^)(NSArray<id<MediaObject>> *))success failure:(void(^)(NSError *))failure;
- (NSURLSessionDataTask *)requestMediaById:(MediaId *)mediaId success:(void(^)(id<MediaObject>))success failure:(void(^)(NSError *))failure;
@end
