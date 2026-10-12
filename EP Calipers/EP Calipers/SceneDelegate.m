#import "SceneDelegate.h"
#import "EPSMainViewController.h"
#import "Version.h"
#import "EPSLogging.h"

static NSString * const SceneStateKey = @"calipersState";

@implementation SceneDelegate

- (EPSMainViewController *)mainViewController {
    UIViewController *root = self.window.rootViewController;
    if (![root isKindOfClass:[UINavigationController class]]) {
        return nil;
    }
    UIViewController *controller = ((UINavigationController *)root).viewControllers.firstObject;
    return [controller isKindOfClass:[EPSMainViewController class]] ? (EPSMainViewController *)controller : nil;
}

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    EPSMainViewController *controller = [self mainViewController];
    Version *version = [[Version alloc] init];
    controller.isUpgrade = [version isUpgrade];
    controller.isNewInstallation = [version isNewInstallation];
    controller.priorVersion = [version getPreviousAppVersion];
    controller.currentVersion = [version getAppVersion];
    controller.priorMajorVersion = [Version getMajorVersion:[version getPreviousAppVersion]];

    // Restore only when no new document was supplied to this launch.
    NSURL *url = connectionOptions.URLContexts.anyObject.URL;
    if (url.isFileURL) {
        controller.launchURL = url;
        controller.launchFromURL = YES;
    } else {
        NSData *data = session.stateRestorationActivity.userInfo[SceneStateKey];
        if ([data isKindOfClass:[NSData class]]) {
            NSError *error = nil;
            NSKeyedUnarchiver *coder = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&error];
            if (coder != nil) {
                coder.requiresSecureCoding = YES;
                coder.decodingFailurePolicy = NSDecodingFailurePolicySetErrorAndReturn;
                [controller loadViewIfNeeded];
                [controller restoreSceneStateWithCoder:coder];
                [coder finishDecoding];
            }
            if (error != nil || coder.error != nil) {
                EPSLog(@"Unable to restore scene: %@", error ?: coder.error);
            }
        }
    }
}

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
    NSURL *url = URLContexts.anyObject.URL;
    if (!url.isFileURL) {
        return;
    }
    EPSMainViewController *controller = [self mainViewController];
    controller.launchURL = url;
    if (!controller.isViewLoaded || controller.firstRun) {
        // The controller opens launch URLs after its first appearance.
        controller.launchFromURL = YES;
    } else {
        [controller openURL:url];
    }
}

- (NSUserActivity *)stateRestorationActivityForScene:(UIScene *)scene {
    EPSMainViewController *controller = [self mainViewController];
    if (!controller.isViewLoaded) {
        return nil;
    }
    NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initRequiringSecureCoding:YES];
    [controller encodeSceneStateWithCoder:coder];
    [coder finishEncoding];
    NSUserActivity *activity = [[NSUserActivity alloc] initWithActivityType:@"org.epstudios.epcalipers.scene"];
    activity.userInfo = @{SceneStateKey: coder.encodedData};
    return activity;
}

- (void)sceneDidEnterBackground:(UIScene *)scene {
    EPSLog(@"sceneDidEnterBackground");
}

@end
