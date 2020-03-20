//
//  Model.m
//  instaMe
//
//  Created by Tom Broadbent on 11/17/16.
//  Copyright © 2016 Tom Broadbent. All rights reserved.
//

#import "Model.h"

@interface ImageMediaObject()
@property (nonatomic) NSInteger id;
@end

@implementation ImageMediaObject

- (id<SpacialObject>)spacial
{
    return self.images.downsized_still.url
        ? self.images.downsized_still
        : nil;
}
- (NSString *)urlAnim
{
    return [self.images.downsized.url length]
        ? self.images.downsized.url
        : nil;
}

+ (JSONKeyMapper *)keyMapper
{
    NSDictionary *keyMap = @{
                             @"imageId": @"id"
                             };
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:keyMap];
}
@end


@implementation ImageObject
@end

@implementation ImagesObject
@end


@implementation Model
@end
