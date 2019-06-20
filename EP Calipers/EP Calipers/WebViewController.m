//
//  WebViewController.m
//  EP Calipers
//
//  Created by David Mann on 4/1/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import "WebViewController.h"
#import "Defs.h"
#import "About.h"
#import "Alert.h"
#import "Translation.h"
#import "EPSLogging.h"

// These can't be yes for release version
#ifdef DEBUG
// Set to yes to use local web page for testing.
#define USE_LOCAL_MANUAL_URL
#endif

#ifdef USE_LOCAL_MANUAL_URL
// MARK: To developers, this absolute path will need to be changed to your
// file scheme.
#define MANUAL_URL @"file://localhost/Users/mannd/dev/epcalipers-ghpages/%@.lproj/EPCalipers-help/newhelp.html#%@"
#else
#define MANUAL_URL @"https://mannd.github.io/epcalipers/%@.lproj/EPCalipers-help/newhelp.html#%@"
#endif

#define LANG L(@"lang")

@interface WebViewController ()
@property (strong, nonatomic) UIActivityIndicatorView *activityView;
@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityView.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0);
    [self.activityView startAnimating];
    [self.view addSubview:self.activityView];

    // If fullLink is nil, add anchor to link.
    NSString *link;
    if (self.fullLink == nil) {
        link = [NSString stringWithFormat:MANUAL_URL, LANG, self.anchor];
    }
    else {
        link = [NSString stringWithFormat:self.fullLink, LANG];
    }
    NSURL *url = [NSURL URLWithString:link];

    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
    self.webView.delegate = self;

    NSString *title = L(@"Help");
    [self.navigationItem setTitle:title];
    
    // centers view with navigationbar in place
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// MARK: - Web view delegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    EPSLog(@"webViewDidFinishLoad");
    [self.activityView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    EPSLog(@"webViewDidFailLoad");
    EPSLog(@"error is %lu", error.code);
    [self.activityView stopAnimating];
    UIAlertController *aboutAlertController = [UIAlertController alertControllerWithTitle:L(@"Error") message:L(@"Internet_connection_failed") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:L(@"OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){[self.navigationController popViewControllerAnimated:YES];}];
    [aboutAlertController addAction:okAction];
    [self presentViewController:aboutAlertController animated:YES completion:nil];
}

@end
