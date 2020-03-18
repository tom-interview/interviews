//
//  ImageDetailController.m
//  instaMe
//
//  Created by Tom Broadbent on 11/17/16.
//  Copyright © 2016 Tom Broadbent. All rights reserved.
//

#import "ImageDetailController.h"
#import "ImagePresentation.h"
#import <FLAnimatedImage.h>
#import <FLAnimatedImageView.h>

@interface ImageDetailController() <ImagePresentationDelegate>
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *imageView;

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

    if (![_imagePresentation hasImage])
    {
        [_imagePresentation requestImage];
    }
    
    if (![_imagePresentation hasImageAnim])
    {
        [_imagePresentation requestImageAnim];
    }
        
    [self updatePresentation];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
- (void)updatePresentation {
    if (self.imagePresentation.imageAnim)
    {
        [self.imageView setAnimatedImage:self.imagePresentation.imageAnim];
    }
    else if (self.imagePresentation.image)
    {
        [self.imageView setImage:self.imagePresentation.image];
    }
}

- (void)updatedImagePresentation:(ImagePresentation *)imagePresentation {
    [self updatePresentation];
    
    if (![_imagePresentation hasImageAnim])
    {
        [_imagePresentation requestImageAnim];
    }
}
@end
