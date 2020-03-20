//
//  GiphyDataSource.m
//  instaMe
//
//  Created by Tom Broadbent on 11/17/16.
//  Copyright © 2016 Tom Broadbent. All rights reserved.
//

#import "GiphyDataSource.h"
#import "State.h"
#import <JSONModel/JSONModel.h>


#pragma mark - ErrorResponse
@interface ErrorResponse : JSONModel
@property (nonatomic) NSString *errorType;
@property (nonatomic) NSString *errorMessage;
@end

@implementation ErrorResponse

+ (JSONKeyMapper *)keyMapper
{
    NSDictionary *keyMap = @{
                             @"errorType": @"meta.error_type",
                             @"errorMessage": @"meta.error_message",
                             };
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:keyMap];
}

@end


#pragma mark - Transceiver

/* extern */ NSString * const TransceiverErrorDomain = @"TransceiverErrorDomain";

@interface GiphyDataSource()
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSString *key;
@end

@implementation GiphyDataSource

- (void)setKey:(NSString *)key {
    _key = key;
    [[State sharedInstance] setApiKey:key];
}

- (NSURLSessionDataTask *)retrieveDataWithRequest:(NSURLRequest *)request success:(void (^)(NSData * _Nullable data))success failure:(void (^)(NSError * _Nullable error))failure {
    if (!request) @throw NSInvalidArgumentException;

    NSURLSessionDataTask *dataTask =
    [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self logResponse:response data:data error:error];

        if (error) {
            failure(error);
            return;
        }

        NSHTTPURLResponse *httpResponse;
        if (![(httpResponse = (NSHTTPURLResponse *)response) isKindOfClass:[NSHTTPURLResponse class]]) {
            failure([NSError errorWithDomain:TransceiverErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"Unrecognized response from service"}]);
            return;
        }

        if (httpResponse.statusCode != 200) { // FIXME handle errors more carefully
            failure([NSError errorWithDomain:TransceiverErrorDomain code:TransceiverErrorCode_Unk userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Expected status=200 (%d)", (int)httpResponse.statusCode]}]);
            return;
        }

        success(data);
        return;
    }];

    [self logRequest:dataTask];
    [dataTask resume];
    return dataTask;
}
- (NSURLSessionDataTask *)retrieveJsonWithRequest:(NSURLRequest *)request success:(void (^)(NSString * _Nullable jsonString))success failure:(void (^)(NSError * _Nullable error))failure {
    return [self retrieveDataWithRequest:request success:^(NSData * _Nullable data) {
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        success(jsonString);
    } failure:failure];
}
- (NSURLSessionTask *)performRequest:(NSURLRequest *)request success:(void (^)(void))success failure:(void (^)(NSError * _Nullable error))failure {
    return [self retrieveDataWithRequest:request success:^(NSData * _Nullable data) {
        success();
    } failure:failure];
}

- (NSMutableURLRequest *)requestWithEndpoint:(NSString *)endpoint queryParams:(NSDictionary <NSString *, NSString *> *)queryParams {
    if (![endpoint length] || [endpoint characterAtIndex:0] != '/') { // FIXME shld be DBC here
        NSLog(@"endpoint must be nonempty and begin w/ '/'");
        @throw NSInvalidArgumentException;
    }

    NSString *urlString = [NSString stringWithFormat:@"http://api.giphy.com%@", endpoint];

    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:urlString];
    NSMutableArray *queryItems = [NSMutableArray array];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"api_key" value:self.key]];
    [queryParams enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull name, NSString *  _Nonnull value, BOOL * _Nonnull stop) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:name value:value]];
    }];
    [urlComponents setQueryItems:queryItems];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[urlComponents URL]];
    return request;
}

#pragma mark - Media requests
- (NSURLSessionDataTask *)retrieveMediaTrendingWithSuccess:(void (^)(NSString * _Nullable))success failure:(void (^)(NSError * _Nullable))failure {
    NSDictionary  *queryParams = @{
        @"limit": @"100", // FIXME expose
        @"rating": @"G"
    };
    
    NSURLRequest *request = [self requestWithEndpoint:@"/v1/gifs/trending" queryParams:queryParams];
    return [self retrieveJsonWithRequest:request success:^(NSString * _Nullable jsonString) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(jsonString);
            });
        }
    } failure:^(NSError * _Nullable error) {
        if (failure) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
        }
    }];
}
- (NSURLSessionDataTask *)retrieveMediaWithQuery:(NSString *)query success:(void (^)(NSString * _Nullable))success failure:(void (^)(NSError * _Nullable))failure {
    NSDictionary *queryParams = @{
        @"q": query,
        @"limit": @"100", // FIXME expose
        @"rating": @"G"
    };

    NSMutableURLRequest *request = [self requestWithEndpoint:@"/v1/gifs/search" queryParams:queryParams];
    return [self retrieveJsonWithRequest:request success:^(NSString * _Nullable jsonString) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(jsonString);
            });
        }
    } failure:^(NSError * _Nullable error) {
        if (failure) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
        }
    }];
}

#pragma mark - Image requests
- (nonnull NSURLSessionDataTask *)retrieveImageAtUrl:(nonnull NSString *)url success:(void (^_Nonnull)(NSData * _Nullable))success failure:(void (^_Nullable)(NSError * _Nullable error))failure {
    if (![url length]) @throw NSInvalidArgumentException;

    return [self retrieveDataWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] success:^(NSData * _Nullable imageData) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(imageData);
            });
        }
    } failure:^(NSError * _Nullable error) {
        if (failure) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
        }
    }];
}


#pragma mark - logging
- (void)logRequest:(NSURLSessionTask *)task {
    NSLog(@"-->> request %d; method: %@; url: %@", (int)task.taskIdentifier, task.originalRequest.HTTPMethod, task.originalRequest.URL.absoluteString);
}
- (void)logResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *)error {
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *truncatedString = ([responseString length] > 200 ? [[responseString substringToIndex:200] stringByAppendingString:@"..."] : responseString);
    NSLog(@"<<-- response url: %@; error: %@\njson: %@", response.URL.absoluteString, error, truncatedString);
}

@end