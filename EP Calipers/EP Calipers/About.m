//
//  About.m
//  EP Calipers
//
//  Created by David Mann on 3/27/17.
//  Copyright © 2017 EP Studios. All rights reserved.
//

#import "About.h"
#import <UIKit/UIKit.h>
#include "Defs.h"

// TODO: update version
#define VERSION @"2.10"

@implementation About

+ (void)show {
    NSString *message = [NSString localizedStringWithFormat:L(@"Copyright © 2015 - 2017 EP Studios, Inc.\nAll rights reserved.\nVersion %@"), VERSION];
    UIAlertView *aboutAlertView = [[UIAlertView alloc] initWithTitle:L(@"EP Calipers") message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    aboutAlertView.alertViewStyle = UIAlertViewStyleDefault;
    [aboutAlertView show];
}

@end
