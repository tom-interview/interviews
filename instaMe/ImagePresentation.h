//
//  ImagePresentation.h
//  instaMe
//
//  Created by Tom Broadbent on 11/17/16.
//  Copyright © 2016 Tom Broadbent. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImagePresentationDelegate;

@interface ImagePresentation : NSObject

@property (strong, nonatomic) NSString *url;
@property (assign, nonatomic) CGSize size;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *label;
@property (weak, nonatomic) NSURLSessionDataTask *dataTask;
@property (weak, nonatomic) id<ImagePresentationDelegate> delegate;

- (instancetype)clone;
- (void)requestImage;
- (void)abandonImage; // FIXME rename

- (instancetype)initWithUrl:(NSString *)url size:(CGSize)size label:(NSString *)label;
+ (instancetype)imagePresentationWithUrl:(NSString *)url size:(CGSize)size label:(NSString *)label;
+ (instancetype)clonePresentation:(ImagePresentation *)presentation;

@end

@protocol ImagePresentationDelegate <NSObject>
- (void)imagePresentation:(ImagePresentation *)imagePresentation didRetrieveImage:(UIImage *)image;
@end

