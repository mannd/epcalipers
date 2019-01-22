//
//  HelpImageViewController.m
//  EP Calipers
//
//  Created by David Mann on 12/26/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

#import "HelpImageViewController.h"
#import "Translation.h"
#import "Defs.h"
#import "EPSLogging.h"

@interface HelpImageViewController ()

@end

@implementation HelpImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    EPSLog(@"HelpImageView did load");
    // Do any additional setup after loading the view.
    self.helpImageView.image = [UIImage imageNamed:self.imageName];
    self.label.text = self.labelText;
    [self.skipButton setTitle:self.skipButtonText forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:YES];
}


- (IBAction)skipAction:(id)sender {
        [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
