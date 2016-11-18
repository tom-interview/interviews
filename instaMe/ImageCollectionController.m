//
//  ImageCollectionController.m
//  instaMe
//
//  Created by Tom Broadbent on 11/17/16.
//  Copyright © 2016 Tom Broadbent. All rights reserved.
//

#import "ImageCollectionController.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "ImageDetailController.h"
#import "ImagePresentation.h"
#import "Model.h"
#import "Transceiver.h"


#pragma mark - ImageCell
@interface ImageCell : UICollectionViewCell <ImagePresentationDelegate>
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *imageLabel;

@property (strong, nonatomic) ImagePresentation *imagePresentation;
@end

@implementation ImageCell

+ (NSString *)reuseId {
    return NSStringFromClass(self);
}
- (void)setImagePresentation:(ImagePresentation *)imagePresentation {
    [_imagePresentation setDelegate:nil];
    [_imagePresentation abandonImage];

    _imagePresentation = imagePresentation;

    [imagePresentation setDelegate:self];
    [imagePresentation requestImage];

    [self updatePresentation];
}
- (void)awakeFromNib {
    [self.containerView.layer setCornerRadius:8];
    [self.containerView setBackgroundColor:[UIColor lightGrayColor]];
}
- (void)updatePresentation {
    [self.imageLabel setText:self.imagePresentation.label];
    [self.imageView setImage:self.imagePresentation.image];
}
- (void)imagePresentation:(ImagePresentation *)imagePresentation didRetrieveImage:(UIImage *)image {
    [self updatePresentation];
}
@end


#pragma mark - ImageCollectionController
@interface ImageCollectionController() <UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout>

@property (strong, nonatomic) NSArray *model;
@property (strong, nonatomic) NSURLSessionDataTask *dataTask;

@end


@implementation ImageCollectionController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.model = @[];

    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    [layout setColumnCount:2];
    [layout setMinimumColumnSpacing:0];
    [layout setMinimumInteritemSpacing:0];
    [self.collectionView setCollectionViewLayout:layout];
    [self.collectionView setDataSource:self];
    [self.collectionView setBackgroundColor:[UIColor colorWithWhite:.92 alpha:1]];

    self.dataTask = [[Model sharedInstance] requestNearbyMediaWithSuccess:^(NSArray<id<MediaObject>> *media) {

        NSMutableArray *model = [NSMutableArray array];

        for (id<MediaObject> m in media) {
            ImageMediaObject *image;
            if ([(image = (ImageMediaObject *)m) isKindOfClass:[ImageMediaObject class]]) {
                [model addObject:[ImagePresentation imagePresentationWithUrl:image.standardImage.url size:CGSizeMake(image.standardImage.width, image.standardImage.height) label:image.user.username]];
            }
        }

        [self setModel:[model copy]];
        [self.collectionView reloadData];
    } failure:^(NSError *error) {
        NSLog(@"unable to refresh data due to error: %@", error);
    }];
}

- (ImagePresentation *)itemAtIndexPath:(NSIndexPath *)indexPath {
    ImagePresentation *item = nil;

    if (indexPath.row < [self.model count]) {
        item = [self.model objectAtIndex:indexPath.row];
    }

    return item;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ImageDetailController *detailController;
    if ([(detailController = (ImageDetailController *)segue.destinationViewController) isKindOfClass:[ImageDetailController class]]) {
        ImageCell *imageCell;
        if ([(imageCell = (ImageCell *)sender) isKindOfClass:[ImageCell class]]) {
            [detailController setImagePresentation:[imageCell.imagePresentation clone]];
        }
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.model count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[ImageCell reuseId] forIndexPath:indexPath];

    ImagePresentation *imagePresentation;
    if ((imagePresentation = [self itemAtIndexPath:indexPath])) {
        [cell setImagePresentation:imagePresentation];
    }

    return cell;
}

#pragma mark - CHTCollectionViewDelegateWaterfallLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeZero;

    ImagePresentation *imagePresentation;
    if ((imagePresentation = [self itemAtIndexPath:indexPath])) {
        size.width = imagePresentation.size.width;
        size.height = imagePresentation.size.height;
    }

    return size;
}


@end
