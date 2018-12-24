//
//  About.m
//  EP Calipers
//
//  Created by David Mann on 3/27/17.
//  Copyright © 2017 EP Studios. All rights reserved.
//

#import "About.h"
#import "Alert.h"
#import "Version.h"
#import <UIKit/UIKit.h>
#include "Defs.h"

@implementation About

+ (void)show {
    NSString *message = [NSString localizedStringWithFormat:L(@"Copyright © 2015-2019 EP Studios, Inc.\nAll rights reserved.\nVersion %@"), [self getVersion]];
    UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [Alert showSimpleAlertWithTitle:L(@"EP Calipers") message:message viewController:vc];
}

+ (NSString *)getVersion {
    Version *version = [[Version alloc] init];
    return [version getAppVersionWithBuild];
}

@end
