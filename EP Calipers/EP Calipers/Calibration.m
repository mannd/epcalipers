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

// State restoration keys
#define UNITS_KEY @"Units"
#define DISPLAY_RATE_KEY @"DisplayRate"
#define CALIBRATED_KEY @"Calibrated"
#define ORIGINAL_ZOOM_KEY @"OriginalZoom"
#define CURRENT_ZOOM_KEY @"CurrentZoom"
#define ORIGINAL_CAL_FACTOR_KEY @"OriginalCalFactor"

@implementation Calibration

@synthesize units=_units;

- (instancetype)initWithDirection:(CaliperDirection)direction {
    self = [super init];
    if (self) {
        [self reset];
        self.originalZoom = 1.0;
        self.currentZoom = 1.0;
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
    // We don't want to change zoom just because we clear calibration
 
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
    [coder encodeObject:self.rawUnits forKey:[self getPrefixedKey:prefix key:UNITS_KEY]];
    [coder encodeBool:self.displayRate forKey:[self getPrefixedKey:prefix key:DISPLAY_RATE_KEY]];
    [coder encodeBool:self.calibrated forKey:[self getPrefixedKey:prefix key:CALIBRATED_KEY]];
    [coder encodeDouble:self.originalZoom forKey:[self getPrefixedKey:prefix key:ORIGINAL_ZOOM_KEY]];
    [coder encodeDouble:self.currentZoom forKey:[self getPrefixedKey:prefix key:CURRENT_ZOOM_KEY]];
    [coder encodeDouble:self.originalCalFactor forKey:[self getPrefixedKey:prefix key:ORIGINAL_CAL_FACTOR_KEY]];
    
}

- (void)decodeCalibrationState:(NSCoder *)coder withPrefix:(NSString *)prefix {
    // this is setting _units.  self.units returns units based on interval/rate
    self.units = [coder decodeObjectOfClass:[NSString class] forKey:[self getPrefixedKey:prefix key:UNITS_KEY]];
    self.displayRate = [coder decodeBoolForKey:[self getPrefixedKey:prefix key:DISPLAY_RATE_KEY]];
    self.calibrated = [coder decodeBoolForKey:[self getPrefixedKey:prefix key:CALIBRATED_KEY]];
    self.originalZoom = [coder decodeDoubleForKey:[self getPrefixedKey:prefix key:ORIGINAL_ZOOM_KEY]];
    self.currentZoom = [coder decodeDoubleForKey:[self getPrefixedKey:prefix key:CURRENT_ZOOM_KEY]];
    self.originalCalFactor = [coder decodeDoubleForKey:[self getPrefixedKey:prefix key:ORIGINAL_CAL_FACTOR_KEY]];
}

@end
