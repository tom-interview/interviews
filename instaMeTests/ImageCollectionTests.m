//
//  ImageCollectionTests.m
//  instaMeTests
//
//  Created by interview on 3/18/20.
//  Copyright © 2020 Tom Broadbent. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "ImageCollectionController.h"
#import "StubMediaObjectSource.h"

@interface ImageCollectionTests : XCTestCase
@property (strong, nonnull) ImageCollectionController *ic;
@property (strong, nonnull) NSString *stubUrl;
@end

@implementation ImageCollectionTests

- (void)setUp {
    self.continueAfterFailure = NO;
    
    self.stubUrl = @"http://stub.url";
    
    UIViewController *vc = UIApplication.sharedApplication.keyWindow.rootViewController;
    UIViewController *rootVC = [(UINavigationController *)vc visibleViewController];
    
    if ([rootVC isKindOfClass:ImageCollectionController.class])
    {
        [self setIc:(ImageCollectionController * _Nonnull)rootVC];
    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testImageCollection_CreatesModel_Success {
    id<MediaObjectSource> source = [[StubMediaObjectSource alloc] initWithUrl:self.stubUrl];
    [self.ic injectMediaObjectSource:source];
    
    [self.ic updateModelWithMode:MediaMode_Search];

    NSArray<ImagePresentation *> *model = [self.ic inspectModel];
    XCTAssertNotNil(model);
    XCTAssertEqual([model count], 1);
    XCTAssertEqual([model.firstObject url], self.stubUrl);
}

- (void)testImageCollection_CreatesModel_OmittingBadObject {
    id spa = OCMProtocolMock(@protocol(SpacialObject));
    id obj = OCMProtocolMock(@protocol(MediaObject));
    [OCMStub([obj spacial]) andReturn:spa];
    
    id<MediaObjectSource> source = [[StubMediaObjectSource alloc] initWithObject:obj];
    [self.ic injectMediaObjectSource:source];
    
    [self.ic updateModelWithMode:MediaMode_Search];

    NSArray<ImagePresentation *> *model = [self.ic inspectModel];
    XCTAssertNotNil(model);
    XCTAssertEqual([model count], 0);
}

@end
