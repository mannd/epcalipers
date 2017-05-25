//
//  About.m
//  EP Calipers
//
//  Created by David Mann on 3/27/17.
//  Copyright © 2017 EP Studios. All rights reserved.
//

#import "About.h"
#import <UIKit/UIKit.h>

// TODO: update version
#define VERSION @"2.7.1"

@implementation About

+ (void)show {
    UIAlertView *aboutAlertView = [[UIAlertView alloc] initWithTitle:@"EP Calipers" message:[NSString stringWithFormat:@"Copyright \u00a9 2015 - 2017 EP Studios, Inc.\nAll rights reserved.\nVersion %@" , VERSION] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    aboutAlertView.alertViewStyle = UIAlertViewStyleDefault;
    [aboutAlertView show];
}

@end
