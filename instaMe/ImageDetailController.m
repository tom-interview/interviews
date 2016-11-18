//
//  ImageDetailController.m
//  instaMe
//
//  Created by Tom Broadbent on 11/17/16.
//  Copyright © 2016 Tom Broadbent. All rights reserved.
//

#import "ImageDetailController.h"
#import "ImagePresentation.h"

@interface ImageDetailController() <ImagePresentationDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) ImagePresentation *imagePresentation;
@end

@implementation ImageDetailController

- (void)setImagePresentation:(ImagePresentation *)imagePresentation {
    _imagePresentation = imagePresentation;
    [_imagePresentation setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [self updatePresentation];
}
- (void)updatePresentation {
    UIImage *image;
    if ((image = self.imagePresentation.image)) {
        [self.imageView setImage:self.imagePresentation.image];
    }
    else {
    }
}

- (void)imagePresentation:(ImagePresentation *)imagePresentation didRetrieveImage:(UIImage *)image {
    [self updatePresentation];
}
@end
