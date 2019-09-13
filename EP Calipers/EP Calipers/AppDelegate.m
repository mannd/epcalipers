//
//  AppDelegate.m
//  EP Calipers
//
//  Created by David Mann on 3/15/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import "AppDelegate.h"
#import "EPSMainViewController.h"
#import "Version.h"
#import "EPSLogging.h"
#import "Translation.h"
#import "Defs.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UINavigationController *navigationController = (UINavigationController *)  self.window.rootViewController;
    EPSMainViewController *mainViewController = (EPSMainViewController *) [navigationController.viewControllers objectAtIndex:0];

    Version *version = [[Version alloc] init];
    mainViewController.isUpgrade = [version isUpgrade];
    mainViewController.isNewInstallation = [version isNewInstallation];
    mainViewController.priorVersion = [version getPreviousAppVersion];
    mainViewController.currentVersion = [version getAppVersion];
    mainViewController.priorMajorVersion = [Version getMajorVersion:[version getPreviousAppVersion]];

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotated) name:NSNotificationCenter.UIDeviceOrientationDidChangeNotification object:nil];
//    NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)

    return YES;
}

// TODO: use this strategy to determine first use vs upgrade.
//- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
//{
//    // ...
//
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//
//    NSString *currentAppVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
//    NSString *previousVersion = [defaults objectForKey:@"appVersion"];
//    if (!previousVersion) {
//        // first launch
//
//        // ...
//
//        [defaults setObject:currentAppVersion forKey:@"appVersion"];
//        [defaults synchronize];
//    } else if ([previousVersion isEqualToString:currentAppVersion]) {
//        // same version
//    } else {
//        // other version
//
//        // ...
//
//        [defaults setObject:currentAppVersion forKey:@"appVersion"];
//        [defaults synchronize];
//    }
//
//
//
//    return YES;
//}


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
                                        nil];
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
    EPSLog(@"applicationDidEnterBackground");
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

- (BOOL)application:(UIApplication *)app openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    EPSLog(@"application:openURL:sourceApplication:annotation");
    
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

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return YES;
}

@end
