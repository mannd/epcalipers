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

@synthesize multiplierForPortrait=_multiplierForPortrait;
@synthesize multiplier=_multiplier;
@synthesize units=_units;


- (instancetype)initWithDirection:(CaliperDirection)direction {
    self = [super init];
    if (self) {
        [self reset];
        self.direction = direction;
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

- (BOOL)isOriginalOrientation:(CGSize)size {
    // TODO make this return true if orientation unchanged from that used for calibration
    return YES;
}

- (NSString *)units {
    if (self.displayRate)
        return @"bpm";
    else if ((self.orientation == Portrait && self.calibratedProtraitMode) ||
        (self.orientation == Landscape && self.calibratedLandscapeMode)) {
            return _units;
        }
    else
        return @"points";
}

- (NSString *)rawUnits {
    return _units;
}

- (double)multiplierForPortrait {
    double multiplier = 1.0;
//    if (!self.calibratedProtraitMode || self.currentOrientationRatio == self.calibratedOrientationRatio) {
//        multiplier = _multiplierForPortrait;
//    }
//    else {
//        multiplier = _multiplierForPortrait * self.currentOrientationRatio;
//    }
    multiplier = _multiplierForPortrait;
    return multiplier;
}

- (void)setMultiplierForPortrait:(double)multiplier {
    _multiplierForPortrait = multiplier;
}

- (double)multiplier {
    if (self.orientation == Portrait) {
        return self.multiplierForPortrait;
    }
    else {
        return self.multiplierForLandscape;
    }
}

- (void)reset {
    self.calibratedProtraitMode = NO;
    self.calibratedLandscapeMode = NO;
    self.units = @"points";
    self.multiplierForPortrait = 1.0;
    self.multiplierForLandscape = 1.0;
    self.currentOrientationRatio = 1.0;
    self.calibratedOrientationRatio = 1.0;
    self.displayRate = NO;
    self.calibratedProtraitMode = NO;
    self.orientation = Portrait;
}

- (BOOL)canDisplayRate {
    if (self.direction == Vertical) {
        return NO;
    }
    return self.unitsAreMsec || self.unitsAreSeconds;
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


@end
