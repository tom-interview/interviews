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

    [self.likeButton.layer setCornerRadius:4];
    [self.likeButton setImage:[[UIImage imageNamed:@"like"] imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)] forState:UIControlStateNormal];
    [self.likeBacker.layer setCornerRadius:7];
}
- (void)updatePresentation {
    [self.imageLabel setText:self.imagePresentation.label];
    [self.imageHeaderLabel setText:self.imagePresentation.headerLabel];
    [self.imageView setImage:self.imagePresentation.image];

    UIColor *tintColor = ([self.imagePresentation isLiked] ? [UIColor colorWithRed:.8 green:0 blue:0 alpha:.6] : [UIColor colorWithWhite:1 alpha:.6]);
    UIColor *buttonColor = ([self.imagePresentation isLiked] ? [UIColor colorWithWhite:.9 alpha:.6] : [UIColor colorWithWhite:.2 alpha:.5]);
    [self.likeButton setTintColor:tintColor];
    [self.likeButton setBackgroundColor:buttonColor];
    [self.likeLabel setTextColor:tintColor];
    [self.likeLabel setText:[self.imagePresentation likeLabel]];
    [self.likeBacker setBackgroundColor:[self.likeLabel.text length] ? [buttonColor colorWithAlphaComponent:1] : [UIColor clearColor]];
}
- (void)imagePresentation:(ImagePresentation *)imagePresentation didRetrieveImage:(UIImage *)image {
    [self updatePresentation];
}

- (IBAction)tappedLikeButton:(UIButton *)b {
    MediaId *mediaId;
    if (![(mediaId = [self.imagePresentation.mediaObject mediaId]) isKindOfClass:[MediaId class]]) {
        NSLog(@"unable to like w/o valid mediaId");
        return;
    }

    [self.likeTimer invalidate];

    [self.imagePresentation setLiked:![self.imagePresentation isLiked]];
    [self updatePresentation];

    NSTimer *likeTimer = [NSTimer scheduledTimerWithTimeInterval:.4 target:self selector:@selector(likeTimerFired:) userInfo:self.imagePresentation repeats:NO];
    [self setLikeTimer:likeTimer];
}
- (void)likeTimerFired:(NSTimer *)t {

    ImagePresentation *imagePresentation;
    if ([(imagePresentation = t.userInfo) isKindOfClass:[ImagePresentation class]]) {

        __weak typeof(self) wSelf = self;
        void (^reload)(void) = ^void(void) {
            __strong typeof(self) sSelf = wSelf;
            if (sSelf) {
                [sSelf.delegate imageCell:sSelf mediaObjectRequiresReload:[imagePresentation.mediaObject mediaId]];
            }
        };

        if ([imagePresentation isLiked]) { // GOTCHA presentation has transient like state here..
            [[Transceiver sharedInstance] likeMediaById:[imagePresentation.mediaObject mediaId] success:^{
                reload();
            } failure:^(NSError * _Nullable error) {
                NSLog(@"unable to like w/ error: %@", error); // FIXME alert user? or reset state to cached state?
                reload();
            }];
        }
        else {
            [[Transceiver sharedInstance] unlikeMediaById:[imagePresentation.mediaObject mediaId] success:^{
                reload();
            } failure:^(NSError * _Nullable error) {
                NSLog(@"unable to unlike w/ error: %@", error); // FIXME alert user? or just reset state to cached state?
                reload();
            }];
        }
    }
}
@end
