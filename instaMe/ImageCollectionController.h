//
//  ImageCollectionController.h
//  instaMe
//
//  Created by Tom Broadbent on 11/17/16.
//  Copyright © 2016 Tom Broadbent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Operations.h"

@interface ImageCollectionController : UICollectionViewController
- (void)injectOperations:(Operations *)operations;

@end
