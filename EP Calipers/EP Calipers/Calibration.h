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

@property BOOL calibrated;
@property CaliperDirection direction;
@property double multiplier;
@property (strong, nonatomic) NSString *units;
@property (strong, nonatomic) NSString *calibrationString;
@property float currentOrientationRatio;
@property float calibratedOrientationRatio;

- (instancetype)initWithDirection:(CaliperDirection)direction withOrientation:(UIDeviceOrientation)orientation;
- (instancetype)init;
- (void)reset;



@end
