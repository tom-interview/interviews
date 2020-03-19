//
//  Model.h
//  instaMe
//
//  Created by Tom Broadbent on 11/17/16.
//  Copyright © 2016 Tom Broadbent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <JSONModel/JSONModel.h>

@interface _Id : NSObject
@property (strong, nonatomic) NSString *objectId;
- (instancetype)initWithId:(NSString *)id;
+ (instancetype)idWithId:(NSString *)id;
@end

@interface UserId : _Id
@end

@interface MediaId : _Id
@end

@protocol SpacialObject <NSObject>
- (NSString *)url;
- (CGFloat)width;
- (CGFloat)height;
@end

@protocol MediaObject <NSObject>
- (MediaId *)mediaId;
- (NSString *)title;
- (id<SpacialObject>)spacial;
- (NSString *)urlAnim;
@end

@interface ImageObject : JSONModel<SpacialObject>
@property (nonatomic) NSString *url;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@end


@interface ImagesObject : JSONModel
@property (nonatomic) ImageObject *downsized; // 2MB
@property (nonatomic) ImageObject *downsized_still;
@property (nonatomic) ImageObject *downsized_large; // 8MB
@property (nonatomic) ImageObject *original;
@end


@interface ImageMediaObject : JSONModel <MediaObject>
@property (nonatomic) MediaId <Ignore> *mediaId;
@property (nonatomic) NSString *imageId;
@property (nonatomic) NSString *title;
@property (nonatomic) ImagesObject *images;
@end


@interface Model : NSObject
@end
