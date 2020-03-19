//
//  instaMeTests.m
//  instaMeTests
//
//  Created by Tom Broadbent on 11/17/16.
//  Copyright © 2016 Tom Broadbent. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Transceiver.h"
#import "Operations.h"

@interface StubMediaSource : NSObject<MediaDataSource>
@end

@implementation StubMediaSource
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

@interface instaMeTests : XCTestCase
@property (strong, nonatomic) id<MediaDataSource> mediaSource;
@property (strong, nonatomic) Operations *operations;
@end

@implementation instaMeTests

- (void)setUp {
    [super setUp];
    [self setMediaSource:[[StubMediaSource alloc] init]];
    
    Operations *ops = [[Operations alloc] initWithMediaSource:self.mediaSource];
    [self setOperations:ops];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testExample {
    [self.operations requestRecentMediaWithSuccess:^(NSArray<id<MediaObject>> * _Nonnull items) {
        NSAssert([items count], @"received zero items");
        XCTAssertNotNil([items.firstObject title]);
    } failure:^(NSError * _Nonnull error) {
        NSAssert(false, @"error requesting items");
    }];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
