//
//  ImagePresentation.h
//  instaMe
//
//  Created by Tom Broadbent on 11/17/16.
//  Copyright © 2016 Tom Broadbent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Model.h"
#import "GiphyDataSource.h"
#import <FLAnimatedImage.h>

@protocol ImagePresentationDelegate;

@interface ImagePresentation : NSObject

@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *urlAnim;
@property (assign, nonatomic) CGSize size;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) FLAnimatedImage *imageAnim;
@property (strong, nonatomic) NSString *label;
@property (strong, nonatomic) NSString *headerLabel;
@property (weak, nonatomic) id<ImagePresentationDelegate> delegate;
@property (strong, nonatomic) id<MediaObject> mediaObject;

- (void)injectMediaDataSource:(id<MediaDataSource>)mediaDataSource;

- (bool)hasImage;
- (bool)hasImageAnim;
- (void)requestImage;
- (void)requestImageAnim;
- (void)abandonTasks;

- (instancetype)initWithUrl:(NSString *)url size:(CGSize)size label:(NSString *)label;
+ (instancetype)imagePresentationWithUrl:(NSString *)url size:(CGSize)size label:(NSString *)label;
+ (instancetype)imagePresentationWithMediaObject:(id<MediaObject>)mediaObject;

@end

@protocol ImagePresentationDelegate <NSObject>
- (void)updatedImagePresentation:(ImagePresentation *)imagePresentation;
@end

