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
#import "Translation.h"
#import <UIKit/UIKit.h>
#import "Defs.h"

@implementation About

+ (void)show {
    NSString *message = [NSString localizedStringWithFormat:L(@"Copyright_message"), [self getVersion]];
    UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [Alert showSimpleAlertWithTitle:L(@"EP Calipers") message:message viewController:vc];
}

+ (NSString *)getVersion {
    Version *version = [[Version alloc] init];
    return [version getAppVersionWithBuild];
}

@end
