//
//  ImageCell.m
//  instaMe
//
//  Created by interview on 3/17/20.
//  Copyright © 2020 Tom Broadbent. All rights reserved.
//

#import "ImageCell.h"
#import "Transceiver.h"

@implementation ImageCell

+ (NSString *)reuseId {
    return NSStringFromClass(self);
}
- (void)setImagePresentation:(ImagePresentation *)imagePresentation {
    [_imagePresentation setDelegate:nil];
    [_imagePresentation abandonTasks];

    _imagePresentation = imagePresentation;

    [imagePresentation setDelegate:self];
    [imagePresentation requestImage];

    [self updatePresentation];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.containerView setBackgroundColor:[UIColor colorWithWhite:.92 alpha:1]];
}
- (void)updatePresentation {
    [self.imageLabel setText:self.imagePresentation.label];
    [self.imageHeaderLabel setText:self.imagePresentation.headerLabel];
    
    [self.imageView setImage:self.imagePresentation.image];
}
- (void)updatedImagePresentation:(ImagePresentation *)imagePresentation {
    [self updatePresentation];
}

@end
