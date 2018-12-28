//
//  HelpImageViewController.m
//  EP Calipers
//
//  Created by David Mann on 12/26/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

#import "HelpImageViewController.h"
#include "Defs.h"

@interface HelpImageViewController ()

@end

@implementation HelpImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.helpImageView.image = [UIImage imageNamed:L(@"Help_image")];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    [btn addTarget:self action:@selector(showHelpTable) forControlEvents:UIControlEventTouchUpInside];
    self.title = L(@"Quick Help");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:YES];

}

- (void)showHelpTable {
    [self performSegueWithIdentifier:@"showHelpTableSegue" sender:self];
}

@end
