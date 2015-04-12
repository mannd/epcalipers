//
//  Calibration.m
//  EP Calipers
//
//  Created by David Mann on 3/27/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import "Calibration.h"
#import "EPSLogging.h"

@implementation Calibration

@synthesize multiplier=_multiplier;
@synthesize units=_units;

- (instancetype)initWithDirection:(CaliperDirection)direction {
    self = [super init];
    if (self) {
        [self reset];
        self.direction = direction;
        self.orientation = Portrait;    // default, but don't clear with reset
    }
    return self;
}

- (instancetype)init {
    self = [self initWithDirection:Horizontal];
    return self;
}

+ (BOOL)isPortraitOrientationForSize:(CGSize)size {
    return size.height > size.width;
}

- (NSString *)units {
    if ((self.orientation == Portrait && self.calibratedProtraitMode) ||
        (self.orientation == Landscape && self.calibratedLandscapeMode)) {
        if (self.displayRate) {
            return @"bpm";
        }
        else {
            return _units;
        }
    }
    else
        return @"points";
}

- (NSString *)rawUnits {
    return _units;
}

- (double)multiplier {
    if (self.zCalibrated) {
        return [self zCurrentCalFactor];
    }
    else
        return 1.0;
    
//    if (self.orientation == Portrait) {
//        return self.multiplierForPortrait;
//    }
//    else {
//        return self.multiplierForLandscape;
//    }
}

- (void)reset {
    self.calibratedProtraitMode = NO;
    self.calibratedLandscapeMode = NO;
    self.units = @"points";
    self.multiplierForPortrait = 1.0;
    self.multiplierForLandscape = 1.0;
    self.displayRate = NO;
    
    self.zCurrentMaximum = 1.0;
    self.zOriginalZoom = 1.0;
    self.zCurrentZoom = 1.0;
    self.zOriginalMaximum = 1.0;
    self.zCalibrated = NO;
}

- (BOOL)canDisplayRate {
    if (self.direction == Vertical) {
        return NO;
    }
    else if (![self currentModeCalibrated]) {
        return NO;
    }
    return self.unitsAreMsec || self.unitsAreSeconds;
}

- (BOOL)currentModeCalibrated {
    return ((self.calibratedProtraitMode && self.orientation == Portrait) || (self.calibratedLandscapeMode && self.orientation == Landscape));
}

- (BOOL)unitsAreSeconds {
    if (_units.length < 1) {
        return NO;
    }
    NSString *units = [_units uppercaseString];
    return [units isEqualToString:@"S"] || [units isEqualToString:@"SEC"] || [units isEqualToString:@"SECOND"]
        || [units isEqualToString:@"SECS"] || [units isEqualToString:@"SECONDS"];
}

- (BOOL)unitsAreMsec {
    if (_units.length < 1) {
        return NO;
    }
    NSString *units = [_units uppercaseString];
    return [units containsString:@"MSEC"] || [units isEqualToString:@"MS"] || [units containsString:@"MILLIS"];
}

- (BOOL)calibratedEitherMode {
    return self.calibratedLandscapeMode || self.calibratedProtraitMode;
}


#pragma Z-functions
- (CGFloat)zCurrentCalFactor {
    return (self.zOriginalMaximum * self.zOriginalZoom * self.zOriginalCalFactor) / (self.zCurrentMaximum * self.zCurrentZoom);
}

- (CGFloat)zCurrentVerticalCalFactor {
    return 1.0;
}

@end
