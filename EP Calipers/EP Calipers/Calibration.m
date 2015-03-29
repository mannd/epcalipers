//
//  Calibration.m
//  EP Calipers
//
//  Created by David Mann on 3/27/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import "Calibration.h"

@implementation Calibration

@synthesize multiplier=_multiplier;


- (instancetype)initWithDirection:(CaliperDirection)direction withOrientation:(UIDeviceOrientation)orientation {
    self = [super init];
    if (self) {
        [self reset];
        self.direction = direction;
    }
    return self;
}

- (instancetype)init {
    self = [self initWithDirection:Horizontal withOrientation:UIDeviceOrientationUnknown];

    return self;
}

- (double)multiplier {
   if (!self.calibrated || self.currentOrientationRatio == self.calibratedOrientationRatio) {
        return _multiplier;
    }
    else {
        return _multiplier * self.currentOrientationRatio;
    }
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
    self.calibrated = NO; 
}


@end
