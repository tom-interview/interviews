//
//  ImageCell.h
//  instaMe
//
//  Created by interview on 3/17/20.
//  Copyright © 2020 Tom Broadbent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImagePresentation.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ImageCellDelegate;

@interface ImageCell : UICollectionViewCell <ImagePresentationDelegate>
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *imageHeaderView;
@property (weak, nonatomic) IBOutlet UILabel *imageHeaderLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIView *likeBacker;
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;
@property (weak, nonatomic) IBOutlet UIView *imageFooterView;
@property (weak, nonatomic) IBOutlet UILabel *imageLabel;

@property (weak, nonatomic) NSTimer *likeTimer; // GOTCHA debounce like taps to avoid thrashing service

@property (strong, nonatomic) ImagePresentation *imagePresentation;
@property (weak, nonatomic) id<ImageCellDelegate>delegate;

- (void)updatePresentation;

+ (NSString *)reuseId;
@end

@protocol ImageCellDelegate <NSObject>
- (void)imageCell:(ImageCell *)imageCell mediaObjectRequiresReload:(MediaId *)mediaId;
@end


NS_ASSUME_NONNULL_END
