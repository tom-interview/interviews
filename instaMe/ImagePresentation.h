//
//  ImagePresentation.h
//  instaMe
//
//  Created by Tom Broadbent on 11/17/16.
//  Copyright © 2016 Tom Broadbent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Model.h"

@protocol ImagePresentationDelegate;

@interface ImagePresentation : NSObject

@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *urlOrig;
@property (assign, nonatomic) CGSize size;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIImage *imageOrig;
@property (strong, nonatomic) NSString *label;
@property (strong, nonatomic) NSString *headerLabel;
@property (weak, nonatomic) NSURLSessionDataTask *dataTask;
@property (weak, nonatomic) id<ImagePresentationDelegate> delegate;
@property (strong, nonatomic) id<MediaObject> mediaObject;

- (BOOL)isLiked;
- (void)setLiked:(BOOL)liked;
- (NSString *)likeLabel; // nil if 0 or single digit or + if > 9 

- (instancetype)clone;

- (bool)hasImage;
- (void)requestImage;
- (void)abandonTasks;

- (instancetype)initWithUrl:(NSString *)url size:(CGSize)size label:(NSString *)label;
+ (instancetype)imagePresentationWithUrl:(NSString *)url size:(CGSize)size label:(NSString *)label;
+ (instancetype)imagePresentationWithImageMediaObject:(ImageMediaObject *)imageMediaObject;
+ (instancetype)clonePresentation:(ImagePresentation *)presentation;

@end

@protocol ImagePresentationDelegate <NSObject>
- (void)imagePresentation:(ImagePresentation *)imagePresentation didRetrieveImage:(UIImage *)image;
@end

