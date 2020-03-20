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


@interface OperationsTests : XCTestCase
@property (strong, nonatomic) id<MediaDataSource> mediaSource;
@property (strong, nonatomic) GiphyObjectSource *operations;
@end

@implementation OperationsTests

- (void)setUp {
    [super setUp];
    [self setMediaSource:[[StubMediaDataSource alloc] init]];
    
    GiphyObjectSource *ops = [[GiphyObjectSource alloc] initWithMediaDataSource:self.mediaSource];
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


@end


