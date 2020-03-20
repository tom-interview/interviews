//
//  ImageCollectionController.h
//  instaMe
//
//  Created by Tom Broadbent on 11/17/16.
//  Copyright © 2016 Tom Broadbent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GiphyObjectSource.h"
#import "ImagePresentation.h"

typedef enum : NSUInteger {
    MediaMode_Trending,
    MediaMode_Search,
} MediaMode;

@interface ImageCollectionController : UICollectionViewController
- (void)injectMediaObjectSource:(id<MediaObjectSource>)source;

// exposed for testing
- (NSArray<ImagePresentation *> *)inspectModel;
- (void)updateModelWithMode:(MediaMode)mode;

@end
