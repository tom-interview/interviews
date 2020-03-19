//
//  StubMediaDataSource.m
//  instaMeTests
//
//  Created by interview on 3/18/20.
//  Copyright © 2020 Tom Broadbent. All rights reserved.
//

#import "StubMediaDataSource.h"

@implementation StubMediaDataSource

- (NSString *)trendingJson
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"jsonTrending" ofType:@"json"];
    NSString* content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    return content;
}

- (nonnull NSURLSessionDataTask *)retrieveMediaTrendingWithSuccess:(void (^_Nonnull)(NSString * _Nullable jsonString))success failure:(void (^_Nullable)(NSError * _Nullable error))failure
{
    success([self trendingJson]);
    return nil;
}
- (nonnull NSURLSessionDataTask *)retrieveMediaWithQuery:(NSString * _Nonnull)query success:(void (^_Nonnull)(NSString * _Nullable jsonString))success failure:(void (^_Nullable)(NSError * _Nullable error))failure
{
    return nil;
}
- (nonnull NSURLSessionDataTask *)retrieveMediaById:(nonnull MediaId *)mediaId success:(void (^_Nonnull)(NSString * _Nullable jsonString))success failure:(void (^_Nullable)(NSError * _Nullable error))failure
{
    return nil;
}

- (nonnull NSURLSessionDataTask *)retrieveImageAtUrl:(nonnull NSString *)url success:(void (^_Nonnull)(NSData * _Nullable))success failure:(void (^_Nullable)(NSError * _Nullable error))failure
{
    return nil;
}

@end

