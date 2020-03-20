//
//  StubMediaObjectSource.h
//  instaMeTests
//
//  Created by interview on 3/18/20.
//  Copyright © 2020 Tom Broadbent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GiphyObjectSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface StubMediaObjectSource : NSObject<MediaObjectSource>
- (instancetype)initWithUrl:(NSString *)url;
- (instancetype)initWithObject:(id<MediaObject>)object;
@end

NS_ASSUME_NONNULL_END
