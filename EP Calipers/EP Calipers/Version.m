//
//  Version.m
//  EP Calipers
//
//  Created by David Mann on 12/24/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

#import "Version.h"

@implementation Version

- (instancetype)initWithVersion:(NSString *)currentVersion previousVersion:(NSString *)previousversion {
    self = [super init];
    if (self) {
        self.currentVersion = currentVersion;
        self.previousVersion = previousversion;
        self.doUnitTest = NO;
    }
    return self;
}

- (NSString *)getPreviousAppVersion {
    if (self.doUnitTest) {
        return self.previousVersion;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *previousVersion = [defaults objectForKey:@"AppVersion"];
    return previousVersion;
}

- (NSString *)getAppVersion {
    if (self.doUnitTest) {
        return self.currentVersion;
    }
    NSDictionary *dictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = dictionary[@"CFBundleShortVersionString"];
    return version;
}

+ (NSString *)getAppVersion {
    NSDictionary *dictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = dictionary[@"CFBundleShortVersionString"];
    return version;
}


- (NSString *)getAppVersionWithBuild {
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

+ (NSString *)getMajorVersion:(NSString *)version {
    // This tests for nil and empty string.
    if ([version length] > 0) {
        NSArray* substrings = [version componentsSeparatedByString:@"."];
        if ([substrings count] > 0) {
            return substrings[0];
        }
    }
    return version;
}

- (BOOL)isNewInstallation {
    NSString *previousVersion = [self getPreviousAppVersion];
    return !previousVersion;
}

- (BOOL)isUpgrade {
    if ([self isNewInstallation]) {
        return NO;
    }
    NSString *currentVersion = [self getAppVersion];
    NSString *previousVersion = [self getPreviousAppVersion];
    return ![currentVersion isEqualToString:previousVersion];
}

@end
