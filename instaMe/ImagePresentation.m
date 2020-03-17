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

- (BOOL)isLiked {
    return false; //(self.transientLiked ? [self.transientLiked boolValue] : [self.mediaObject isLikedByUser]);
}
- (void)setLiked:(BOOL)liked {
    [self setTransientLiked:[NSNumber numberWithBool:liked]];
}
- (NSString *)likeLabel {
    NSInteger likeCount = 0; //[self.mediaObject likeCount];
    NSString *likeLabel = (likeCount <= 0 ? nil : likeCount > 10 ? @"+" : [NSNumber numberWithInteger:likeCount].stringValue);
    return likeLabel;
}
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

    CGSize size = CGSizeMake(imageMediaObject.images.downsized.width, imageMediaObject.images.downsized.height);
    ImagePresentation *presentation = [self imagePresentationWithUrl:imageMediaObject.images.downsized.url size:size label:imageMediaObject.title];
    [presentation setMediaObject:imageMediaObject];

    return presentation;
}

+ (instancetype)clonePresentation:(ImagePresentation *)presentation {
    ImagePresentation *clone = [self imagePresentationWithUrl:presentation.url size:presentation.size label:presentation.label];
    [clone setImage:presentation.image];
    [clone setMediaObject:presentation.mediaObject];
    return clone;
}
- (instancetype)clone {
    return [self.class clonePresentation:self];
}

- (void)requestImage {
    if (!self.image && !self.dataTask && self.url) {
        self.dataTask = [[Transceiver sharedInstance] retrieveImageAtUrl:self.url success:^(NSData * _Nullable imageData) {
            UIImage *image;
            if (imageData && (image = [UIImage imageWithData:imageData])) {
                [self setImage:image];
                [self.delegate imagePresentation:self didRetrieveImage:image];
            }
            else {
                // FIXME handle error
            }
        } failure:nil]; // FIXME handle error
    }
}
- (void)abandonImage { // FIXME rename
    [self.dataTask cancel];
    [self setDataTask:nil];
}
- (NSString *)description {
    return [NSString stringWithFormat:@"url: %@; label: %@; size: %@; hasImage: %@", _url, _label, NSStringFromCGSize(_size), (_image ? @"YES" : @"NO")];
}


@end
