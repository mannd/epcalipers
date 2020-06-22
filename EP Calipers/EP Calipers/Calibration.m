//
//  Calibration.m
//  EP Calipers
//
//  Created by David Mann on 3/27/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import "Calibration.h"
#import "EP_Calipers-Swift.h"
#import "EPSLogging.h"
#import "Translation.h"
#import "Defs.h"

@implementation Calibration

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
    if (self.calibrated) {
        if (self.displayRate) {
            return L(@"bpm");
        }
        else {
            return _units;
        }
    }
    else
        return L(@"points");
}

- (NSString *)rawUnits {
    return _units;
}

- (double)multiplier {
    if (self.calibrated) {
        return [self currentCalFactor];
    }
    else
        return 1.0;
}

- (void)reset {
    self.units = L(@"points");
    self.displayRate = NO;
    self.originalZoom = 1.0;
    self.currentZoom = 1.0;
    self.calibrated = NO;
}

- (BOOL)canDisplayRate {
    if (self.direction == Vertical) {
        return NO;
    }
    else if (![self calibrated]) {
        return NO;
    }
    return self.unitsAreMsec || self.unitsAreSeconds;
}

- (BOOL)unitsAreSeconds {
    // Note that _units.length < 1 is true when _units == nil, so need this.
    if (_units.length < 1 || self.direction == Vertical) {
        return NO;
    }
    return [CalibrationProcessor matchesSec:self.rawUnits];
}

- (BOOL)unitsAreMsec {
    // Note that _units.length < 1 is true when _units == nil, so need this.
    if (_units.length < 1 || self.direction == Vertical) {
        return NO;
    }
    return [CalibrationProcessor matchesMsec:self.rawUnits];
}

- (BOOL)unitsAreMM {
    if (_units.length < 1 || self.direction != Vertical) {
        return NO;
    }
    return [CalibrationProcessor matchesMM:self.rawUnits];
}

- (CGFloat)currentCalFactor {
    return (self.originalZoom * self.originalCalFactor) / self.currentZoom;
}

- (NSString *)getPrefixedKey:(NSString *)prefix key:(NSString *)key {
    return [NSString stringWithFormat:@"%@%@", prefix, key];
}

- (void)encodeCalibrationState:(NSCoder *)coder withPrefix:(NSString *)prefix {
    // rawUnits is just _units.  However self.units returns units based on interval/rate
    [coder encodeObject:self.rawUnits forKey:[self getPrefixedKey:prefix key:@"Units"]];
    [coder encodeBool:self.displayRate forKey:[self getPrefixedKey:prefix key:@"DisplayRate"]];
    [coder encodeBool:self.calibrated forKey:[self getPrefixedKey:prefix key:@"Calibrated"]];
    [coder encodeDouble:self.originalZoom forKey:[self getPrefixedKey:prefix key:@"OriginalZoom"]];
    [coder encodeDouble:self.currentZoom forKey:[self getPrefixedKey:prefix key:@"CurrentZoom"]];
    [coder encodeDouble:self.originalCalFactor forKey:[self getPrefixedKey:prefix key:@"OriginalCalFactor"]];
    
}

- (void)decodeCalibrationState:(NSCoder *)coder withPrefix:(NSString *)prefix {
    // this is setting _units.  self.units returns units based on interval/rate
    self.units = [coder decodeObjectForKey:[self getPrefixedKey:prefix key:@"Units"]];
    self.displayRate = [coder decodeBoolForKey:[self getPrefixedKey:prefix key:@"DisplayRate"]];
    self.calibrated = [coder decodeBoolForKey:[self getPrefixedKey:prefix key:@"Calibrated"]];
    self.originalZoom = [coder decodeDoubleForKey:[self getPrefixedKey:prefix key:@"OriginalZoom"]];
    self.currentZoom = [coder decodeDoubleForKey:[self getPrefixedKey:prefix key:@"CurrentZoom"]];
    self.originalCalFactor = [coder decodeDoubleForKey:[self getPrefixedKey:prefix key:@"OriginalCalFactor"]];
}

@end
