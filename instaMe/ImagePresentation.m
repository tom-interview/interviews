//
//  ImagePresentation.m
//  instaMe
//
//  Created by Tom Broadbent on 11/17/16.
//  Copyright © 2016 Tom Broadbent. All rights reserved.
//

#import "ImagePresentation.h"
#import "Model.h"
#import "GiphyDataSource.h"

@interface ImagePresentation()
@property (strong, nonatomic) id<MediaDataSource> mediaDataSource;
@property (weak, nonatomic) NSURLSessionDataTask *dataTask;
@property (assign, nonatomic) bool fetchingAnim;
@end

@implementation ImagePresentation

- (void)injectMediaDataSource:(id<MediaDataSource>)mediaDataSource
{
    [self setMediaDataSource:mediaDataSource];
}

- (void)setMediaObject:(id<MediaObject>)mediaObject {
    _mediaObject = mediaObject;
}

- (instancetype)initWithUrl:(NSString *)url size:(CGSize)size label:(NSString *)label {
    if ((self = [super init])) {
        _url = url;
        _size = size;
        _label = label;
    }
    return self;
}
+ (instancetype)imagePresentationWithUrl:(NSString *)url size:(CGSize)size label:(NSString *)label {
    return [[self alloc] initWithUrl:url size:size label:label];
}
+ (instancetype)imagePresentationWithMediaObject:(id<MediaObject>)mediaObject {

    CGSize size = CGSizeMake(mediaObject.spacial.width, mediaObject.spacial.height);
    ImagePresentation *presentation = [self imagePresentationWithUrl:mediaObject.spacial.url size:size label:mediaObject.title];
    [presentation setUrlAnim:mediaObject.urlAnim	];
    [presentation setMediaObject:mediaObject];

    return presentation;
}

- (bool)isFetchingAnim {
    return self.fetchingAnim;
}
- (bool)hasImage {
    return self.image != nil;
}
- (bool)hasImageAnim {
    return self.imageAnim != nil;
}
- (void)requestImage {
    if (!self.image && !self.dataTask && self.url) {
        __weak typeof(self) wSelf = self;
        wSelf.dataTask = [self.mediaDataSource retrieveImageAtUrl:self.url success:^(NSData * _Nullable imageData) {
            __strong typeof(self) sSelf = wSelf;
            UIImage *image;
            if (imageData && (image = [UIImage imageWithData:imageData])) {
                [sSelf setImage:image];
                [sSelf.delegate updatedImagePresentation:sSelf];
            }
            else {
                // FIXME handle error
            }
        } failure:nil]; // FIXME handle error
    }
}
- (void)requestImageAnim {
    if (!self.imageAnim && !self.fetchingAnim && self.urlAnim) {
        [self setFetchingAnim:true];
        __weak typeof(self) wSelf = self;
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            __strong typeof(self) sSelf = wSelf;
            NSURL *url;
            FLAnimatedImage *image;
            if ((url = [NSURL URLWithString:sSelf.urlAnim])
                && (image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:url]])) {
                [sSelf setImageAnim:image];
                [sSelf setFetchingAnim:false];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [sSelf.delegate updatedImagePresentation:sSelf];
                });
            }
            else {
                [sSelf setFetchingAnim:false];
                // FIXME handle error
            }
        });
    }
}
- (void)abandonTasks {
    [self.dataTask cancel];
    [self setDataTask:nil];
}
- (NSString *)description {
    return [NSString stringWithFormat:@"url: %@; label: %@; size: %@; hasImage: %@", _url, _label, NSStringFromCGSize(_size), (_image ? @"YES" : @"NO")];
}


@end
