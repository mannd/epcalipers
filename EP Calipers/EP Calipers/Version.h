//
//  Version.h
//  EP Calipers
//
//  Created by David Mann on 12/24/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Version : NSObject

@property (strong, nonatomic, nullable) NSString *currentVersion;
@property (strong, nonatomic, nullable) NSString *previousVersion;

// For testing, for testing.
@property (nonatomic) BOOL doUnitTest;

// This init is just for testing.
- (instancetype)initWithVersion:(NSString *)currentVersion previousVersion:(NSString *)previousversion;

- (NSString *)getPreviousAppVersion;
- (NSString *)getAppVersion;
+ (NSString *)getAppVersion;
- (NSString *)getAppVersionWithBuild;
+ (NSString *)getMajorVersion:(NSString *)version;
- (BOOL)isNewInstallation;
- (BOOL)isUpgrade;

@end

NS_ASSUME_NONNULL_END
