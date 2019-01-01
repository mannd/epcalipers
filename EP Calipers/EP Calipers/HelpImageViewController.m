//
//  HelpImageViewController.m
//  EP Calipers
//
//  Created by David Mann on 12/26/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

#import "HelpImageViewController.h"
#include "Defs.h"
#import "EPSLogging.h"

@interface HelpImageViewController ()

@end

@implementation HelpImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    EPSLog(@"HelpImageView did load");
    // Do any additional setup after loading the view.
    self.title = L(@"Quick Help");
    self.helpImageView.image = [UIImage imageNamed:self.imageName];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:YES];
}

@end
