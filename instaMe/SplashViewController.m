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
@property (weak, nonatomic) IBOutlet UIButton *authButton;
@property (weak, nonatomic) IBOutlet UIView *promptView;

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.authButton setTitle:@"Next" forState:UIControlStateNormal];
    [self.authButton.layer setCornerRadius:4];
    [self.authButton setBackgroundColor:[UIColor lightGrayColor]];
    [self.authButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (IBAction)tappedAuthButton:(UIButton *)b {
    [self performSegueWithIdentifier:@"PresentImages" sender:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
