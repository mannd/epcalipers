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
#import "EPSLogging.h"

// These can't be yes for release version
#ifdef DEBUG
// Set to yes to use local web page for testing.
#define USE_LOCAL_MANUAL_URL YES
#else
#define USE_LOCAL_MANUAL_URL NO
#define SHOW_PDF_MENU NO
#endif
#ifdef USE_LOCAL_MANUAL_URL
// MARK: To developers, this absolute path will need to be changed to your
// file scheme.
#define MANUAL_URL @"file://localhost/Users/mannd/dev/epcalipers-ghpages/%@.lproj/EPCalipers-help/epcalipers_help.html#%@"
#else
#define MANUAL_URL @"https://mannd.github.io/epcalipers/%@.lproj/EPCalipers-help/epcalipers_help.html#%@"
#endif

#define EN @"en"
#define FR @"fr"
#define RU @"ru"

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

    // Add anchor to link.
    NSString *link = [NSString stringWithFormat:MANUAL_URL, L(@"lang"), self.anchor];
    NSURL *url = [NSURL URLWithString:link];

    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
    self.webView.delegate = self;

    NSString *title = L(@"Manual");
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
    UIAlertController *aboutAlertController = [UIAlertController alertControllerWithTitle:L(@"Error") message:L(@"Internet connection failed.") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:L(@"OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){[self.navigationController popViewControllerAnimated:YES];}];
    [aboutAlertController addAction:okAction];
    [self presentViewController:aboutAlertController animated:YES completion:nil];
}

@end
