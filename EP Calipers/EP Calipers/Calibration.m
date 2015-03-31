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
    }
    return self;
}

- (instancetype)init {
    self = [self initWithDirection:Horizontal];

    return self;
}

- (NSString *)units {
    if (self.displayRate)
        return @"bpm";
    else
        return _units;
}

- (NSString *)rawUnits {
    return _units;
}

- (double)multiplier {
    double multiplier = 1.0;
    if (!self.calibrated || self.currentOrientationRatio == self.calibratedOrientationRatio) {
        multiplier = _multiplier;
    }
    else {
        multiplier = _multiplier * self.currentOrientationRatio;
    }
//    if (self.displayRate && self.canDisplayRate) {
//        if (self.unitsAreMsec) {
//            multiplier = multiplier / 60000.0;
//        }
//        if (self.unitsAreSeconds) {
//            multiplier = 60.0 / multiplier;
//        }
//    }
    return multiplier;
}

- (void)setMultiplier:(double)multiplier {
    _multiplier = multiplier;
}

- (void)reset {
    self.calibrated = NO;
    self.units = @"points";
    self.multiplier = 1.0;
    self.currentOrientationRatio = 1.0;
    self.calibratedOrientationRatio = 1.0;
    self.displayRate = NO;
    self.calibrated = NO; 
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
