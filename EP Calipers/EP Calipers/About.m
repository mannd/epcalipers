//
//  About.m
//  EP Calipers
//
//  Created by David Mann on 3/27/17.
//  Copyright © 2017 EP Studios. All rights reserved.
//

#import "About.h"
#import "Alert.h"
#import <UIKit/UIKit.h>
#include "Defs.h"

@implementation About

+ (void)show {
    NSString *message = [NSString localizedStringWithFormat:L(@"Copyright © 2015 - 2018 EP Studios, Inc.\nAll rights reserved.\nVersion %@"), [self getVersion]];
    UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [Alert showSimpleAlertWithTitle:L(@"EP Calipers") message:message viewController:vc];
}

+ (NSString *)getVersion {
    NSDictionary *dictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = dictionary[@"CFBundleShortVersionString"];
#ifdef DEBUG // Get build number, if you want it. Cleaner to leave out of release version.
    NSString *build = dictionary[@"CFBundleVersion"];
    // the version+build format is recommended by https://semver.org
    NSString *versionBuild = [NSString stringWithFormat:@"%@+%@", version, build];
    return versionBuild;
#else
    return version;
#endif
}

@end
