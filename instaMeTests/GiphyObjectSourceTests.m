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


@interface GiphyObjectSourceTests : XCTestCase
@property (strong, nonatomic) GiphyObjectSource *giphyObjectSource;
@end

@implementation GiphyObjectSourceTests

- (void)setUp {
    [super setUp];
    id<MediaDataSource> stubSource = [[StubMediaDataSource alloc] init];
    
    GiphyObjectSource *objectSource = [[GiphyObjectSource alloc] initWithMediaDataSource:stubSource];
    [self setGiphyObjectSource:objectSource];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testGiphyObjectSource_TrendingMediaParse_Success {
    [self.giphyObjectSource requestTrendingMediaWithSuccess:^(NSArray<id<MediaObject>> * _Nonnull items) {
        NSAssert([items count], @"received zero items");

        id<MediaObject> media = items.firstObject;
        XCTAssertNotNil(media);
        XCTAssertNotNil([media title]);
        XCTAssertNotNil([media urlAnim]);
        XCTAssertNotNil([media.spacial url]);
        XCTAssertNotEqual([media.spacial width], 0);
        XCTAssertNotEqual([media.spacial height], 0);
        
    } failure:^(NSError * _Nonnull error) {
        NSAssert(false, @"error requesting items");
    }];
}


@end


