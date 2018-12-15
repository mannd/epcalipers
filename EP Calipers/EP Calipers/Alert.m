//
//  Alert.m
//  EP Calipers
//
//  Created by David Mann on 12/15/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

#import "Alert.h"
#include "Defs.h"

@implementation Alert

+ (void)showSimpleAlertWithTitle:(NSString *)title message:(NSString *)message viewController:(UIViewController *)vc {
    UIAlertController *aboutAlertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:L(@"OK") style:UIAlertActionStyleCancel handler:nil];
    [aboutAlertController addAction:okAction];
    [vc presentViewController:aboutAlertController animated:YES completion:nil];
}

@end
