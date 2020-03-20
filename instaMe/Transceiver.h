//
//  Transceiver.h
//  instaMe
//
//  Created by Tom Broadbent on 11/17/16.
//  Copyright © 2016 Tom Broadbent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Model.h"

extern NSString * const _Nonnull TransceiverErrorDomain;

typedef enum : NSUInteger {
    TransceiverErrorCode_Unk,
    TransceiverErrorCode_AuthRequired,
} TransceiverErrorCode;

@protocol MediaDataSource <NSObject>

- (nonnull NSURLSessionDataTask *)retrieveMediaTrendingWithSuccess:(void (^_Nonnull)(NSString * _Nullable jsonString))success failure:(void (^_Nullable)(NSError * _Nullable error))failure;
- (nonnull NSURLSessionDataTask *)retrieveMediaWithQuery:(NSString * _Nonnull)query success:(void (^_Nonnull)(NSString * _Nullable jsonString))success failure:(void (^_Nullable)(NSError * _Nullable error))failure;

- (nonnull NSURLSessionDataTask *)retrieveImageAtUrl:(nonnull NSString *)url success:(void (^_Nonnull)(NSData * _Nullable))success failure:(void (^_Nullable)(NSError * _Nullable error))failure;

@end


@interface Transceiver : NSObject<MediaDataSource>

- (void)setToken:(nullable NSString *)token;
- (void)setKey:(nullable NSString *)key;
- (BOOL)isAuthenticated;

@end
