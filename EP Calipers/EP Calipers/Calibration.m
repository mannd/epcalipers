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
    if (self.calibrated) {
        return [self currentCalFactor];
    }
    else
        return 1.0;
}

- (void)reset {
    self.units = @"points";
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
    if (_units.length < 1 || self.direction == Vertical) {
        return NO;
    }
    NSString *units = [_units uppercaseString];
    return [units isEqualToString:@"S"] || [units isEqualToString:@"SEC"] || [units isEqualToString:@"SECOND"]
        || [units isEqualToString:@"SECS"] || [units isEqualToString:@"SECONDS"];
}

- (BOOL)unitsAreMsec {
    if (_units.length < 1 || self.direction == Vertical) {
        return NO;
    }
    NSString *units = [_units uppercaseString];
    return [units containsString:@"MSEC"] || [units isEqualToString:@"MS"] || [units containsString:@"MILLIS"];
}

- (CGFloat)currentCalFactor {
    return (self.originalZoom * self.originalCalFactor) / self.currentZoom;
}

- (BOOL)unitsAreMM {
    if (self.units.length < 1 || self.direction != Vertical) {
        return NO;
    }
    NSString *units = [self.units uppercaseString];
    return [units isEqualToString:@"MM"] || [units containsString:@"MILLIM"];
}

- (NSString *)getPrefixedKey:(NSString *)prefix key:(NSString *)key {
    return [NSString stringWithFormat:@"%@%@", prefix, key];
}

- (void)encodeCalibrationState:(NSCoder *)coder withPrefix:(NSString *)prefix {
    [coder encodeObject:self.units forKey:[self getPrefixedKey:prefix key:@"Units"]];
    [coder encodeBool:self.displayRate forKey:[self getPrefixedKey:prefix key:@"DisplayRate"]];
    [coder encodeBool:self.calibrated forKey:[self getPrefixedKey:prefix key:@"Calibrated"]];
    [coder encodeDouble:self.originalZoom forKey:[self getPrefixedKey:prefix key:@"OriginalZoom"]];
    [coder encodeDouble:self.currentZoom forKey:[self getPrefixedKey:prefix key:@"CurrentZoom"]];
    [coder encodeDouble:self.originalCalFactor forKey:[self getPrefixedKey:prefix key:@"OriginalCalFactor"]];
}

- (void)decodeCalibrationState:(NSCoder *)coder withPrefix:(NSString *)prefix {
    self.units = [coder decodeObjectForKey:[self getPrefixedKey:prefix key:@"Units"]];
    self.displayRate = [coder decodeBoolForKey:[self getPrefixedKey:prefix key:@"DisplayRate"]];
    self.calibrated = [coder decodeBoolForKey:[self getPrefixedKey:prefix key:@"Calibrated"]];
    self.originalZoom = [coder decodeDoubleForKey:[self getPrefixedKey:prefix key:@"OriginalZoom"]];
    self.currentZoom = [coder decodeDoubleForKey:[self getPrefixedKey:prefix key:@"CurrentZoom"]];
    self.originalCalFactor = [coder decodeDoubleForKey:[self getPrefixedKey:prefix key:@"OriginalCalFactor"]];
}



@end
