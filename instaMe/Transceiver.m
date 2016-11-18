//
//  Transceiver.m
//  instaMe
//
//  Created by Tom Broadbent on 11/17/16.
//  Copyright © 2016 Tom Broadbent. All rights reserved.
//

#import "Transceiver.h"

#define TransceiverErrorDomain @"TransceiverErrorDomain"

@interface Transceiver()
@property (strong, nonatomic) NSString *token;
@end

@implementation Transceiver

- (BOOL)isAuthenticated {
    return ([self.token length] > 0);
}

+ (instancetype)sharedInstance {
    static Transceiver *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

- (NSURLSessionDataTask *)retrieveDataWithRequest:(NSURLRequest *)request success:(void (^)(NSData * _Nullable data))success failure:(void (^)(NSError * _Nullable error))failure {

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

        if (httpResponse.statusCode != 200) {
            failure([NSError errorWithDomain:TransceiverErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Expected status=200 (%d)", (int)httpResponse.statusCode]}]);
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

- (NSMutableURLRequest *)requestWithEndpoint:(NSString *)endpoint queryParams:(NSDictionary <NSString *, NSString *> *)queryParams {

    if (![endpoint length] || [endpoint characterAtIndex:0] != '/') { // FIXME shld be DBC here
        NSLog(@"endpoint must be nonempty and begin w/ '/'");
        @throw NSInvalidArgumentException;
    }

    NSString *urlString = [NSString stringWithFormat:@"https://api.instagram.com/v1%@", endpoint];

    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:urlString];
    NSMutableArray *queryItems = [NSMutableArray array];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"access_token" value:self.token]];
    [queryParams enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull name, NSString *  _Nonnull value, BOOL * _Nonnull stop) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:name value:value]];
    }];
    [urlComponents setQueryItems:queryItems];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[urlComponents URL]];
    return request;
}

- (NSURLSessionDataTask *)retrieveMediaForAuthenticatedUserWithSuccess:(void (^)(NSString * _Nullable jsonString))success failure:(void (^)(NSError * _Nullable error))failure {
    NSURLRequest *request = [self requestWithEndpoint:@"/users/self/media/recent" queryParams:nil];
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
- (NSURLSessionDataTask *)retrieveMediaNearLocationCoordinate:(CLLocationCoordinate2D)coordinate success:(void (^)(NSString * _Nullable))success failure:(void (^)(NSError * _Nullable))failure {
    NSDictionary *queryParams = @{
                                  @"lat": [[NSNumber numberWithDouble:coordinate.latitude] stringValue],
                                  @"lng": [[NSNumber numberWithDouble:coordinate.longitude] stringValue],
                                  };

    NSMutableURLRequest *request = [self requestWithEndpoint:@"/media/search" queryParams:queryParams];
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

- (NSArray<id<MediaObject>> *)retrieveMediaForUser:(User *)user {
    @throw NSGenericException; // not implemented
}

- (nonnull NSURLSessionDataTask *)retrieveImageAtUrl:(nonnull NSString *)url success:(void (^_Nonnull)(NSData * _Nullable))success failure:(void (^_Nullable)(NSError * _Nullable error))failure {
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

- (void)logRequest:(NSURLSessionTask *)task {
    NSLog(@">>>> request %d; url: %@", (int)task.taskIdentifier, task.originalRequest.URL.absoluteString);
}
- (void)logResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *)error {
    NSLog(@"<<<< response url: %@; error: %@\njson: %@", response.URL.absoluteString, error, [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] substringToIndex:200]);
}

@end
