//
//  Model.m
//  instaMe
//
//  Created by Tom Broadbent on 11/17/16.
//  Copyright © 2016 Tom Broadbent. All rights reserved.
//

#import "Model.h"

@implementation _Id

- (instancetype)initWithId:(NSString *)id {
    if ((self = [super init])) {
        _objectId = id;
    }
    return self;
}
+ (instancetype)idWithId:(NSString *)id {
    return [[self alloc] initWithId:id];
}

- (BOOL)isEqual:(id)other {
    if (self == other) {
        return YES;
    }

    return [self isEqualToId:other];
}
- (BOOL)isEqualToId:(_Id *)other {
    if (!other) {
        return NO;
    }
    if (![other isKindOfClass:[self class]]) {
        return NO;
    }

    return (self.objectId && [self.objectId isEqualToString:other.objectId]);
}

- (NSUInteger)hash {
    return [self.objectId hash];
}

@end

@implementation UserId
@end
@implementation MediaId
@end


@interface User()
@property (nonatomic) NSInteger id;
@end

@implementation User
- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err {
    if ((self = [super initWithDictionary:dict error:err])) {
        [self setUserId:[[UserId alloc] initWithId:[NSNumber numberWithInteger:_id].stringValue]];
    }
    return self;
}

+ (JSONKeyMapper *)keyMapper
{
    NSDictionary *keyMap = @{
                             @"fullname": @"full_name",
                             };
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:keyMap];
}
@end


@interface ImageMediaObject()
@property (nonatomic) NSInteger id;
@end

@implementation ImageMediaObject

- (BOOL)isLikedByUser {
    return false;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err {
    if ((self = [super initWithDictionary:dict error:err])) {
        [self setMediaId:[[MediaId alloc] initWithId:[NSNumber numberWithInteger:_id].stringValue]];
    }
    return self;
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
