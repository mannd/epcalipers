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

#define ACKNOWLEDGMENTS_URL @"EPCalipers-help/acknowledgments"
#define EN @"en"
#define FR @"fr"
#define RU @"ru"
#define HELP_URL @"https://mannd.github.io/epcalipers/%@.lproj/EPCalipers-help/epcalipers_help.html"

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:HELP_URL, L(@"lang")]];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
    
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

@end
