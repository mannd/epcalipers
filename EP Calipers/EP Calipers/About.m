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

+ (void)showFromViewController:(UIViewController *)viewController {
    NSString *message = [NSString localizedStringWithFormat:L(@"Copyright_message"), [self getVersion]];
    [Alert showSimpleAlertWithTitle:L(@"EP Calipers") message:message viewController:viewController];
}

+ (NSString *)getVersion {
    Version *version = [[Version alloc] init];
    return [version getAppVersionWithBuild];
}

@end
