//
//  Calibration.m
//  EP Calipers
//
//  Created by David Mann on 3/27/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import "Calibration.h"

@implementation Calibration

- (instancetype)initWithDirection:(CaliperDirection)direction withOrientation:(UIDeviceOrientation)orientation {
    self = [super init];
    if (self) {
        self.units = @"points";
        self.multiplier = 1.0;
        self.calibrated = NO;
        self.direction = direction;
        self.orientation = orientation;
    }
    return self;
}

- (instancetype)init {
    self = [self initWithDirection:Horizontal withOrientation:UIDeviceOrientationUnknown];

    return self;
}


@end
