//
//  WebViewController.m
//  EP Calipers
//
//  Created by David Mann on 4/1/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import "WebViewController.h"

#define VERSION @"1.0"

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(goBack)];
    UIBarButtonItem *aboutButton = [[UIBarButtonItem alloc] initWithTitle:@"About" style:UIBarButtonItemStylePlain target:self action:@selector(showAbout)];
    
    NSArray *array = [NSArray arrayWithObjects:aboutButton, backButton, nil];
    [self.toolbar setItems:array];
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"epcalipers_help" ofType:@"html"] isDirectory:NO];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)goBack {
    [self performSegueWithIdentifier:@"DismissWebViewSegue" sender:nil];
  
}

- (void)showAbout {
    UIAlertView *aboutAlertView = [[UIAlertView alloc] initWithTitle:@"EP Calipers" message:[NSString stringWithFormat:@"Copyright \u00a9 2015 EP Studios, Inc.\nAll rights reserved.\nVersion %@" , VERSION] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    aboutAlertView.alertViewStyle = UIAlertViewStyleDefault;
    [aboutAlertView show];
    
}
@end
