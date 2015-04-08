//
//  Calibration.h
//  EP Calipers
//
//  Created by David Mann on 3/27/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Defs.h"

@interface Calibration : NSObject
#import "Defs.h"

@property BOOL calibratedProtraitMode;
@property BOOL calibratedLandscapeMode;

@property CaliperDirection direction;
@property InterfaceOrientation orientation;
@property double multiplierForPortrait;
@property double multiplierForLandscape;
@property (readonly) double multiplier;
@property (strong, nonatomic) NSString *units;
@property (strong, nonatomic) NSString *calibrationString;
@property (readonly) BOOL canDisplayRate;
@property (readonly) BOOL unitsAreSeconds;
@property (readonly) BOOL unitsAreMsec;
@property BOOL displayRate;

- (instancetype)initWithDirection:(CaliperDirection)direction;
- (instancetype)init;
- (void)reset;
- (BOOL)calibratedEitherMode;
- (BOOL)currentModeCalibrated;
- (NSString *)rawUnits;


+ (BOOL)isPortraitOrientationForSize:(CGSize)size;

@end
