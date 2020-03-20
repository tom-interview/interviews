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

@protocol SpacialObject <NSObject>
- (NSString *)url;
- (CGFloat)width;
- (CGFloat)height;
@end

@protocol MediaObject <NSObject>
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
@property (nonatomic) ImageObject <Optional> *downsized; // 2MB
@property (nonatomic) ImageObject <Optional> *downsized_still;
@property (nonatomic) ImageObject <Optional> *downsized_large; // 8MB
@property (nonatomic) ImageObject <Optional> *original;
@end


@interface ImageMediaObject : JSONModel <MediaObject>
@property (nonatomic) NSString *imageId;
@property (nonatomic) NSString *title;
@property (nonatomic) ImagesObject *images;
@end


@interface Model : NSObject
@end
