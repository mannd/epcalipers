//
//  WebViewController.m
//  EP Calipers
//
//  Created by David Mann on 4/1/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import "WebViewController.h"

//TODO: Update with each new version!!
#define VERSION @"2.5"

#define HELP_URL @"EPCalipers-help/epcalipers_help"

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:HELP_URL ofType:@"html"] isDirectory:NO];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeInfoLight];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    [btn addTarget:self action:@selector(showAbout) forControlEvents:UIControlEventTouchUpInside];
    NSString *title = @"Help";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        title = @"EP Calipers Help";
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)showAbout {
    UIAlertView *aboutAlertView = [[UIAlertView alloc] initWithTitle:@"EP Calipers" message:[NSString stringWithFormat:@"Copyright \u00a9 2015, 2016 EP Studios, Inc.\nAll rights reserved.\nVersion %@" , VERSION] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    aboutAlertView.alertViewStyle = UIAlertViewStyleDefault;
    [aboutAlertView show];
    
}
@end
