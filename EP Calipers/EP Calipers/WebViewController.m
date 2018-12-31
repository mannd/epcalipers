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

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:ACKNOWLEDGMENTS_URL ofType:@"html"] isDirectory:NO];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
    
    NSString *title = L(@"Acknowledgments");
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
