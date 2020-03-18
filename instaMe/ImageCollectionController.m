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

@protocol ImageCellDelegate;

@interface ImageCell : UICollectionViewCell <ImagePresentationDelegate>
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *imageHeaderView;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIView *likeBacker;
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;
@property (weak, nonatomic) IBOutlet UIView *imageFooterView;
@property (weak, nonatomic) IBOutlet UILabel *imageLabel;

@property (weak, nonatomic) NSTimer *likeTimer; // GOTCHA debounce like taps to avoid thrashing service

@property (strong, nonatomic) ImagePresentation *imagePresentation;
@property (weak, nonatomic) id<ImageCellDelegate>delegate;

@end

@protocol ImageCellDelegate <NSObject>
- (void)imageCell:(ImageCell *)imageCell mediaObjectRequiresReload:(MediaId *)mediaId;
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
    [self.containerView setBackgroundColor:[UIColor colorWithWhite:.92 alpha:1]];

    [self.likeButton.layer setCornerRadius:4];
    [self.likeButton setImage:[[UIImage imageNamed:@"like"] imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)] forState:UIControlStateNormal];
    [self.likeBacker.layer setCornerRadius:7];
}
- (void)updatePresentation {
    [self.imageLabel setText:self.imagePresentation.label];
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


typedef enum : NSUInteger {
    MediaMode_Recent,
    MediaMode_Nearby,
} MediaMode;

#pragma mark - ImageCollectionController
@interface ImageCollectionController() <UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout, ImageCellDelegate>

@property (assign, nonatomic) MediaMode mode;
@property (strong, nonatomic) NSArray *model;
@property (weak, nonatomic) NSURLSessionDataTask *dataTask;

@property (weak, nonatomic) UIBarButtonItem *modeButton;

@end


@implementation ImageCollectionController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Nav controller
    UIBarButtonItem *modeButton = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(tappedModeButton:)];
    [self.navigationItem setRightBarButtonItem:modeButton];
    [self setModeButton:modeButton];

    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemStop) target:self action:@selector(tappedLogoutButton:)];
    [self.navigationItem setLeftBarButtonItem:logoutButton];


    // Collection controller
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(pulledRefreshControl:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refreshControl];

    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    [layout setColumnCount:2];
    [layout setMinimumColumnSpacing:0];
    [layout setMinimumInteritemSpacing:0];
    [self.collectionView setCollectionViewLayout:layout];
    [self.collectionView setDataSource:self];
    [self.collectionView setBackgroundColor:[UIColor colorWithWhite:.88 alpha:1]];


    // Initial state
    self.model = @[];
    [self updateModelWithMode:MediaMode_Nearby];
    [self updatePresentation];
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

- (void)updatePresentation {
    BOOL isLoading = (self.dataTask && !(self.dataTask.state == NSURLSessionTaskStateCompleted));
    [self setTitle:(isLoading ? @"Loading..."
                    : self.mode == MediaMode_Recent ? @"Trending" // FIXME get from string table
                    : self.mode == MediaMode_Nearby ? @"Coronavirus"
                    : nil)];

    [self.modeButton setImage:[UIImage imageNamed:(self.mode == MediaMode_Recent ? @"compass" : @"clock")]];
}
- (void)updateModelMediaObject:(id<MediaObject>)mediaObject reload:(BOOL)reload {
    [self.model enumerateObjectsUsingBlock:^(ImagePresentation * _Nonnull p, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[mediaObject mediaId] isEqual:[p.mediaObject mediaId]]) {
            ImagePresentation *imagePresentation = [p clone];
            [imagePresentation setMediaObject:mediaObject];

            NSMutableArray *mutableModel = [self.model mutableCopy];
            [mutableModel replaceObjectAtIndex:idx withObject:imagePresentation];
            [self setModel:[mutableModel copy]];

            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:0]; // FIXME consider sections at some point..

            ImageCell *imageCell;
            if (!reload && [(imageCell = (ImageCell *)[self.collectionView cellForItemAtIndexPath:indexPath]) isKindOfClass:[ImageCell class]]) {
                [imageCell setImagePresentation:imagePresentation];
                [imageCell updatePresentation];
            }
            else if (reload) {
                [self.collectionView performBatchUpdates:^{
                    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                } completion:nil];
            }

            *stop = YES;
        }
    }];
}
- (void)updateModelWithMediaObjects:(NSArray <id<MediaObject>> *)mediaObjects {

    for (ImagePresentation *p in self.model) {
        [p abandonImage];
    }

    NSMutableArray *model = [NSMutableArray array];

    for (id<MediaObject> m in mediaObjects) {
        ImageMediaObject *image;
        if ([(image = (ImageMediaObject *)m) isKindOfClass:[ImageMediaObject class]]) {
            [model addObject:[ImagePresentation imagePresentationWithImageMediaObject:image]];
        }
    }

    // FIXME support dynamic updates

    [self setModel:[model copy]];
    [self.collectionView reloadData];
    [self updatePresentation];
}
- (void)updateModelWithMode:(MediaMode)mode {

    [self.dataTask cancel];
    [self setDataTask:nil];

    __weak typeof(self) wSelf = self;
    void (^success)(NSArray<id<MediaObject>> *) = ^void(NSArray<id<MediaObject>> *media) {
        __strong typeof(self) sSelf = wSelf;
        if (sSelf) {
            [sSelf updateModelWithMediaObjects:media];
        }
    };

    void (^failure)(NSError *) = ^void(NSError *error) {
        __strong typeof(self) sSelf = wSelf;
        if (sSelf) {
            if ([error.domain isEqualToString:TransceiverErrorDomain] && error.code == TransceiverErrorCode_AuthRequired) {
                [sSelf dismissViewControllerAnimated:YES completion:nil];
            }
        }
    };

    NSURLSessionDataTask *dataTask;

    switch(mode) {
        case MediaMode_Recent:
            dataTask = [[Model sharedInstance] requestRecentMediaWithSuccess:success failure:failure];
            break;

        case MediaMode_Nearby:
            dataTask = [[Model sharedInstance] requestNearbyMediaWithSuccess:success failure:failure];
            break;

        default:
            NSLog(@"unsupported mode: %d", (int)mode);
            @throw NSInvalidArgumentException;
    }

    [self setDataTask:dataTask];
    [self setMode:mode];
    [self updatePresentation];
}

#pragma mark - UI callbacks
- (void)tappedModeButton:(UIBarButtonItem *)b {
    [self updateModelWithMode:(self.mode == MediaMode_Recent ? MediaMode_Nearby : MediaMode_Recent)]; // FIXME needs more smarts when modes > 2
}
- (void)tappedLogoutButton:(UIBarButtonItem *)b {
    [[Transceiver sharedInstance] setToken:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)pulledRefreshControl:(UIRefreshControl *)r {
    [self updateModelWithMode:self.mode];
    [r endRefreshing];
}

#pragma mark - ImageCellDelegate
- (void)imageCell:(ImageCell *)imageCell mediaObjectRequiresReload:(MediaId *)mediaId {
    __weak typeof(self) wSelf = self;
    [[Model sharedInstance] requestMediaById:mediaId success:^(id<MediaObject> mediaObject) {
        __strong typeof(self) sSelf = wSelf;
        if (sSelf) {
            [sSelf updateModelMediaObject:mediaObject reload:NO];
        }
    } failure:^(NSError *error) {
        NSLog(@"unable to reload media object w/ error: %@", error); // FIXME error handling
    }];
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
        [cell setDelegate:self];
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
