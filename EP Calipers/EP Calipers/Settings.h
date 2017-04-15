//
//  Settings.h
//  EP Calipers
//
//  Created by David Mann on 3/27/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Settings : NSObject

@property (strong, nonatomic) UIColor *caliperColor;
@property (strong, nonatomic) UIColor *highlightColor;
@property (nonatomic) NSInteger lineWidth;
@property (strong, nonatomic) NSString *defaultCalibration;
@property (strong, nonatomic) NSString *defaultVerticalCalibration;
@property (nonatomic) BOOL roundMsecRate;
@property (nonatomic) BOOL allowTweakDuringQtc;

- (instancetype)init;
- (void)loadPreferences;

@end
