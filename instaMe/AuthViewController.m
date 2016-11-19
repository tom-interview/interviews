//
//  AuthViewController.m
//  instaMe
//
//  Created by Tom Broadbent on 11/17/16.
//  Copyright © 2016 Tom Broadbent. All rights reserved.
//

#import "AuthViewController.h"
#import "Transceiver.h"

@interface ErrorPresentation : NSObject
@property (strong, nonatomic) NSString *errorTitle;
@property (strong, nonatomic) NSString *errorMessage;
@property (strong, nonatomic) NSString *errorButton;
@end

@implementation ErrorPresentation
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message button:(NSString *)button {
    if ((self = [super init])) {
        _errorTitle = title;
        _errorMessage = message;
        _errorButton = button;
    }
    return self;
}
+ (instancetype)errorPresentationWithTitle:(NSString *)title message:(NSString *)message button:(NSString *)button {
    return  [[self alloc] initWithTitle:title message:message button:button];
}
@end


@interface AuthViewController() <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *errorView;
@property (weak, nonatomic) IBOutlet UILabel *errorMessage;
@property (weak, nonatomic) IBOutlet UIButton *errorButton;
@property (weak, nonatomic) IBOutlet UIView *loadingView;

- (NSString *)clientId;
- (NSString *)redirectHost;
- (NSString *)redirectUrl;
@end

@implementation AuthViewController

- (NSString *)clientId {
    //return @"b039af725bfa48a5bcfd5a3f4a3933dd"; // my sandbox
    return @"0637825256de4d9e9c969ec594b032c8"; // 23andMe sandbox
}
- (NSString *)redirectHost {
    //return @"tombroadbent.me";
    return @"www.23andme.com";
}
- (NSString *)redirectUrl {
    return [NSString stringWithFormat:@"https://%@", self.redirectHost];
}
- (NSString *)scopes {
    NSArray *scopes = @[ @"basic",
                         @"public_content",
                         @"likes",
                         ];
    return [scopes componentsJoinedByString:@"+"];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initPresentation];

    [self.webView setDelegate:self];
    [self presentAuthentication];
}
- (void)initPresentation {
    [self.errorMessage setTextColor:[UIColor darkGrayColor]];
    [self.errorButton.layer setCornerRadius:4];
    [self.errorButton setBackgroundColor:[UIColor lightGrayColor]];
    [self.errorButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];

    [self.loadingView.layer setCornerRadius:8];
    [self.loadingView setBackgroundColor:[UIColor colorWithWhite:.2 alpha:.6]];
}
- (void)presentAuthentication {
    [self.webView setHidden:NO];
    [self.errorView setHidden:YES];


    NSString *authString = [NSString stringWithFormat:@"https://api.instagram.com/oauth/authorize/?scope=%@&client_id=%@&redirect_uri=%@&response_type=token", self.scopes, self.clientId, self.redirectUrl];
    NSURL *authUrl = [NSURL URLWithString:authString];
    NSURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:authUrl];

    [self.webView loadRequest:request];
    [self.loadingView setHidden:NO];
}
- (void)presentUnauthorizedWithError:(NSString *)error {
    [self.errorView setHidden:NO];
    [self.webView setHidden:YES];


    ErrorPresentation *errorPresentation = [self errorPresentationForError:error];
    [self.errorMessage setText:errorPresentation.errorMessage];
    [self.errorButton setTitle:errorPresentation.errorButton forState:UIControlStateNormal];
}

- (IBAction)tappedErrorButton:(UIButton *)b {
    [self presentAuthentication];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    BOOL shouldLoad = YES;

    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:request.URL resolvingAgainstBaseURL:NO];
    if ([urlComponents.host containsString:self.redirectHost]) {
        shouldLoad = NO;

        if ([urlComponents.fragment containsString:@"access_token="]) {
            NSArray *parts = [urlComponents.fragment componentsSeparatedByString:@"="];

            NSString *token;
            if ([parts count] > 1 && (token = [parts lastObject])) {
                NSLog(@"token: %@", token);
                [[Transceiver sharedInstance] setToken:token];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else {
                [self presentUnauthorizedWithError:nil];
            }
        }
        else {
            for (NSURLQueryItem *item in urlComponents.queryItems) {
                if ([item.name isEqualToString:@"error"]) {
                    NSLog(@"error: %@", item.value); // FIXME handle error better
                    [[Transceiver sharedInstance] setToken:nil];
                    [self presentUnauthorizedWithError:item.value];
                }
            }
        }
    }

    return shouldLoad;
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error {
    if ([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102) { // GOTCHA 102 is "Frame load interrupted" caused by above; anything else is a legit load error
        NSLog(@"caught reload error; nothing wrong..");
    }
    else {
        NSLog(@"error: %@", error);
        [self presentUnauthorizedWithError:nil];
    }
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.loadingView setHidden:YES];
}

#pragma mark - helpers
- (nonnull ErrorPresentation *)errorPresentationForError:(NSString *)error {
    ErrorPresentation *errorPresentation = [ErrorPresentation errorPresentationWithTitle:@"Unknown Error" message:@"An unknown error occurred." button:@"Retry"];

    if ([error isEqualToString:@"access_denied"]) {
        errorPresentation = [ErrorPresentation errorPresentationWithTitle:@"Access Denied" message:@"Access is required to proceed." button:@"Try Again"];
    }

    return errorPresentation;
}

@end
