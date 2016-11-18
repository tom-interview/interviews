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

@interface Transceiver : NSObject

- (void)setToken:(nullable NSString *)token;
- (BOOL)isAuthenticated;

+ (nonnull instancetype)sharedInstance;

- (nonnull NSURLSessionDataTask *)retrieveMediaForAuthenticatedUserWithSuccess:(void (^_Nonnull)(NSString * _Nullable jsonString))success failure:(void (^_Nullable)(NSError * _Nullable error))failure;
- (nonnull NSURLSessionDataTask *)retrieveMediaNearLocationCoordinate:(CLLocationCoordinate2D)coordinate success:(void (^_Nonnull)(NSString * _Nullable jsonString))success failure:(void (^_Nullable)(NSError * _Nullable error))failure;
- (nonnull NSURLSessionDataTask *)retrieveImageAtUrl:(nonnull NSString *)url success:(void (^_Nonnull)(NSData * _Nullable))success failure:(void (^_Nullable)(NSError * _Nullable error))failure;
@end
