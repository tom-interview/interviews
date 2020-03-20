//
//  instaMeTests.m
//  instaMeTests
//
//  Created by Tom Broadbent on 11/17/16.
//  Copyright © 2016 Tom Broadbent. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "StubMediaDataSource.h"
#import "GiphyObjectSource.h"


@interface MediaObjectSourceTests : XCTestCase
@property (strong, nonatomic) GiphyObjectSource *mediaObjectSource;
@end

@implementation MediaObjectSourceTests

- (void)setUp {
    [super setUp];
    id<MediaDataSource> stubSource = [[StubMediaDataSource alloc] init];
    
    GiphyObjectSource *ops = [[GiphyObjectSource alloc] initWithMediaDataSource:stubSource];
    [self setMediaObjectSource:ops];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testMediaObjectSource_TrendingMediaParse_Success {
    [self.mediaObjectSource requestTrendingMediaWithSuccess:^(NSArray<id<MediaObject>> * _Nonnull items) {
        NSAssert([items count], @"received zero items");
        XCTAssertNotNil([items.firstObject title]);
    } failure:^(NSError * _Nonnull error) {
        NSAssert(false, @"error requesting items");
    }];
}


@end


