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

@property (nonatomic) CaliperDirection direction;
@property (strong, nonatomic) NSString *units;
@property (strong, nonatomic) NSString *calibrationString;
@property (readonly) BOOL canDisplayRate;
@property (readonly) BOOL unitsAreSeconds;
@property (readonly) BOOL unitsAreMsec;
@property (nonatomic) BOOL displayRate;
@property (readonly) double multiplier;
@property (readonly) BOOL unitsAreMM;

- (instancetype)initWithDirection:(CaliperDirection)direction;
- (instancetype)init;
- (void)reset;
- (NSString *)rawUnits;

@property (nonatomic) CGFloat originalZoom;
@property (nonatomic) CGFloat currentZoom;
@property (nonatomic) CGFloat originalCalFactor;
@property (nonatomic) BOOL calibrated;

- (CGFloat)currentCalFactor;

// encode/decode state
- (void)encodeCalibrationState:(NSCoder *)coder withPrefix:(NSString *)prefix;
- (void)decodeCalibrationState:(NSCoder *)coder withPrefix:(NSString *)prefix;

@end
