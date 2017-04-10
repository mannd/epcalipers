//
//  AppDelegate.m
//  EP Calipers
//
//  Created by David Mann on 3/15/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import "AppDelegate.h"
#import "EPSMainViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSDictionary *defaultPreferences = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"roundMsecRatePreference", [NSNumber numberWithBool:NO], @"hideStartImagePreference", [NSNumber numberWithInt:2], @"lineWidthPreference", @"1000 msec", @"calibrationPreference", @"10 mm", @"verticalCalibrationPreference", @"Blue", @"caliperColorPreference", @"Red", @"highlightColorPreference", nil];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultPreferences];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    UINavigationController *navigationController = (UINavigationController *)  self.window.rootViewController;
    EPSMainViewController *mainViewController = (EPSMainViewController *) [navigationController.viewControllers objectAtIndex:0];


    if (url != nil && [url isFileURL]) {
        // Note that openURL won't run the first time program loads, so we pass the relevant info
        // to mainViewController which calls openURL in viewDidLoad.
        mainViewController.launchFromURL = YES;
        mainViewController.launchURL = url;
        [mainViewController openURL:url];
    }
    return YES;
}

@end
