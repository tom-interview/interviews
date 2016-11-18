//
//  ViewController.m
//  instaMe
//
//  Created by Tom Broadbent on 11/17/16.
//  Copyright © 2016 Tom Broadbent. All rights reserved.
//

#import "SplashViewController.h"
#import "Transceiver.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    NSString *segueId;
    if ([Transceiver.sharedInstance isAuthenticated]) {
        segueId = @"PresentImages";
    }
    else {
        segueId = @"PresentAuth";
    }

    [self performSegueWithIdentifier:segueId sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
