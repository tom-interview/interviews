//
//  ImageCollectionController.m
//  instaMe
//
//  Created by Tom Broadbent on 11/17/16.
//  Copyright © 2016 Tom Broadbent. All rights reserved.
//

#import "ImageCollectionController.h"
#import "ImageCell.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "ImageDetailController.h"
#import "ImagePresentation.h"
#import "Model.h"
#import "GiphyObjectSource.h"
#import "GiphyDataSource.h"
#import "AppDelegate.h"



#pragma mark - ImageCollectionController
@interface ImageCollectionController() <UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout, ImageCellDelegate>

@property (strong, nonatomic) id<MediaObjectSource> mediaObjectSource;
@property (assign, nonatomic) MediaMode mode;
@property (strong, nonatomic) NSArray<ImagePresentation *> *model;
@property (weak, nonatomic) NSURLSessionDataTask *dataTask;

@property (weak, nonatomic) UIBarButtonItem *modeButton;

@end


@implementation ImageCollectionController

- (void)injectMediaObjectSource:(id<MediaObjectSource>)mediaObjectSource
{
    [self setMediaObjectSource:mediaObjectSource];
}
- (NSArray<ImagePresentation *> *)inspectModel
{
    return self.model;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.mediaObjectSource) {
        id delegate = [[UIApplication sharedApplication] delegate];
        AppDelegate *appDelegate;
        if ([(appDelegate = (AppDelegate *)delegate) isKindOfClass:AppDelegate.class]){
            [self setMediaObjectSource:appDelegate.mediaObjectSource];
        }
    }

    // Nav controller
    UIBarButtonItem *modeButton = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(tappedModeButton:)];
    [self.navigationItem setRightBarButtonItem:modeButton];
    [self setModeButton:modeButton];

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
    
    [item injectMediaDataSource:self.mediaObjectSource.mediaDataSource];
    
    return item;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ImageDetailController *detailController;
    if ([(detailController = (ImageDetailController *)segue.destinationViewController) isKindOfClass:[ImageDetailController class]]) {
        ImageCell *imageCell;
        if ([(imageCell = (ImageCell *)sender) isKindOfClass:[ImageCell class]]) {
            [detailController setImagePresentation:imageCell.imagePresentation];
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

- (void)updateModelWithMediaObjects:(NSArray <id<MediaObject>> *)mediaObjects {

    for (ImagePresentation *p in self.model) {
        [p abandonTasks];
    }

    NSMutableArray *model = [NSMutableArray array];

    for (id<MediaObject> m in mediaObjects) {
        if ([m.spacial.url length]) // GOTCHA sometimes bogus images in model
        {
            [model addObject:[ImagePresentation imagePresentationWithMediaObject:m]];
        }
    }

    // FIXME support dynamic collection updates

    [self setModel:[model copy]];
    [self.collectionView reloadData];
    [self updatePresentation];
}
- (void)updateModelWithMode:(MediaMode)mode {

    [self.dataTask cancel];
    [self setDataTask:nil];
    
    bool scrollToTop = self.mode != mode;

    __weak typeof(self) wSelf = self;
    void (^success)(NSArray<id<MediaObject>> *) = ^void(NSArray<id<MediaObject>> *media) {
        __strong typeof(self) sSelf = wSelf;
        if (sSelf) {
            [sSelf updateModelWithMediaObjects:media];
            if (scrollToTop) {
                [wSelf.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathWithIndex:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
            }
        }
    };

    void (^failure)(NSError *) = ^void(NSError *error) {
        __strong typeof(self) sSelf = wSelf;
        if (sSelf) {
            // FIXME update UI with error
        }
    };

    NSURLSessionDataTask *dataTask;

    switch(mode) {
        case MediaMode_Recent:
            dataTask = [self.mediaObjectSource requestTrendingMediaWithSuccess:success failure:failure];
            break;

        case MediaMode_Nearby:
            dataTask = [self.mediaObjectSource requestSearchMediaWithSuccess:success failure:failure];
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
- (void)pulledRefreshControl:(UIRefreshControl *)r {
    [self updateModelWithMode:self.mode];
    [r endRefreshing];
}

#pragma mark - ImageCellDelegate

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
