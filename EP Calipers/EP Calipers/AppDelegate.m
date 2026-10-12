//
//  AppDelegate.m
//  EP Calipers
//
//  Created by David Mann on 3/15/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import "AppDelegate.h"
#import "SceneDelegate.h"
#import "Translation.h"
#import "Defs.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSDictionary *defaultPreferences = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:YES], @"roundMsecRatePreference",
                                        [NSNumber numberWithInt:2], @"lineWidthPreference",
                                        L(@"1000 msec"), @"calibrationPreference",
                                        L(@"10 mm"), @"verticalCalibrationPreference",
                                        @"Blue", @"caliperColorPreference",
                                        @"Red", @"highlightColorPreference",
                                        [NSNumber numberWithBool:YES], @"autopositionPreference",
                                        @"0", @"timeTextPositionPreference",
                                        @"3", @"amplitudeTextPositionPreference",
                                        [NSNumber numberWithBool:YES], @"showWarningDialogsPreference", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultPreferences];
    
    return YES;
}

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Supply the scene configuration in code so UIKit owns the storyboard window.
    UISceneConfiguration *configuration = [[UISceneConfiguration alloc] initWithName:nil sessionRole:connectingSceneSession.role];
    configuration.sceneClass = [UIWindowScene class];
    configuration.delegateClass = [SceneDelegate class];
    configuration.storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return configuration;
}

@end
