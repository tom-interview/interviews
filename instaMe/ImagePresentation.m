//
//  ImagePresentation.m
//  instaMe
//
//  Created by Tom Broadbent on 11/17/16.
//  Copyright © 2016 Tom Broadbent. All rights reserved.
//

#import "ImagePresentation.h"
#import "Model.h"
#import "Transceiver.h"

@interface ImagePresentation()
@property (strong, nonatomic) NSNumber *transientLiked; // user has tapped like button; keep track of transient state until item refreshes
@end

@implementation ImagePresentation

- (void)setMediaObject:(id<MediaObject>)mediaObject {
    _mediaObject = mediaObject;
    [self setTransientLiked:nil];
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
+ (instancetype)imagePresentationWithImageMediaObject:(ImageMediaObject *)imageMediaObject {

    CGSize size = CGSizeMake(imageMediaObject.images.downsized_still.width, imageMediaObject.images.downsized_still.height);
    ImagePresentation *presentation = [self imagePresentationWithUrl:imageMediaObject.images.downsized_still.url size:size label:imageMediaObject.title];
    [presentation setHeaderLabel:imageMediaObject.imageId];
    [presentation setUrlAnim:imageMediaObject.images.downsized.url];
    [presentation setMediaObject:imageMediaObject];

    return presentation;
}

+ (instancetype)clonePresentation:(ImagePresentation *)presentation {
    ImagePresentation *clone = [self imagePresentationWithUrl:presentation.url size:presentation.size label:presentation.label];
    [clone setHeaderLabel:presentation.headerLabel];
    [clone setUrlAnim:presentation.urlAnim];
    [clone setImage:presentation.image];
    [clone setImageAnim:presentation.imageAnim];
    [clone setMediaObject:presentation.mediaObject];
    return clone;
}
- (instancetype)clone {
    return [self.class clonePresentation:self];
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
        self.dataTask = [[Transceiver sharedInstance] retrieveImageAtUrl:self.url success:^(NSData * _Nullable imageData) {
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
    if (!self.imageAnim && self.urlAnim) {
        __weak typeof(self) wSelf = self;
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            __strong typeof(self) sSelf = wSelf;
            NSURL *url;
            FLAnimatedImage *image;
            if ((url = [NSURL URLWithString:sSelf.urlAnim])
                && (image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:url]])) {
                [sSelf setImageAnim:image];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [sSelf.delegate updatedImagePresentation:sSelf];
                });
            }
            else {
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
