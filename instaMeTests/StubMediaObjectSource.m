//
//  StubMediaObjectSource.m
//  instaMeTests
//
//  Created by interview on 3/18/20.
//  Copyright © 2020 Tom Broadbent. All rights reserved.
//

#import "StubMediaObjectSource.h"
#import <OCMock/OCMock.h>

@interface StubSpacialObject : NSObject<SpacialObject>
@end

@implementation StubSpacialObject
- (NSString *)url { return nil; }
- (CGFloat)width { return 200; }
- (CGFloat)height { return 200; }
@end


@interface StubMediaObjectSource()
@property (strong, nonnull) id<MediaDataSource> mediaDataSource;
@property (strong, nonnull) NSString *url;
@property (strong, nonnull) id<MediaObject> object;
@end

@implementation StubMediaObjectSource

- (instancetype)initWithUrl:(NSString *)url
{
    if ((self = [super init]))
    {
        [self setUrl:url];
    }
    return self;
}
- (instancetype)initWithObject:(id<MediaObject>)object
{
    if ((self = [super init]))
    {
        [self setObject:object];
    }
    return self;
}

- (id<MediaObject>)getObject
{
    id<MediaObject> o = nil;
    
    if (!self.object)
    {
        id spa = OCMPartialMock([StubSpacialObject new]);
        [OCMStub([spa url]) andReturn:self.url];
        
        id obj = OCMProtocolMock(@protocol(MediaObject));
        [OCMStub([obj spacial]) andReturn:spa];
        
        o = obj;
    }
    
    return o ? o : self.object;
}

- (nonnull NSURLSessionDataTask *)requestSearchMediaWithQuery:(NSString *)query success:(nonnull void (^)(NSArray<id<MediaObject>> * _Nonnull))success failure:(nonnull void (^)(NSError * _Nonnull))failure {
    NSMutableArray *objs = [[NSMutableArray alloc] init];

    [objs addObject:[self getObject]];

    success([[NSArray alloc] initWithArray:objs]);
    
    return nil;
}

- (nonnull NSURLSessionDataTask *)requestTrendingMediaWithSuccess:(nonnull void (^)(NSArray<id<MediaObject>> * _Nonnull))success failure:(nonnull void (^)(NSError * _Nonnull))failure {
    NSMutableArray *objs = [[NSMutableArray alloc] init];

    [objs addObject:[self getObject]];

    success([[NSArray alloc] initWithArray:objs]);
     
    return nil;
}

@end
