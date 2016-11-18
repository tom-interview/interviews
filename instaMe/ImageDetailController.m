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
- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor colorWithWhite:.6 alpha:1]];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self updatePresentation];
}
- (void)updatePresentation {
    UIImage *image;
    if ((image = self.imagePresentation.image)) {
        [self.imageView setImage:self.imagePresentation.image];
    }
}

- (void)imagePresentation:(ImagePresentation *)imagePresentation didRetrieveImage:(UIImage *)image {
    [self updatePresentation];
}
@end
