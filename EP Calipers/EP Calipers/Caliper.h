//
//  Caliper.h
//  EP Calipers
//
//  Created by David Mann on 3/25/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Calibration.h"

@interface Caliper : NSObject
#import "Defs.h"


@property float bar1Position;
@property float bar2Position;
@property float crossBarPosition;
@property CaliperDirection direction;
@property UIColor *color;
@property UIColor *unselectedColor;
@property UIColor *selectedColor;
@property NSInteger lineWidth;
@property (readonly) float valueInPoints;
@property BOOL selected;
@property (weak, nonatomic) Calibration *calibration;

- (double)intervalResult;
- (double)rateResult:(double)interval;
- (double)calibratedResult;
- (instancetype)initWithDirection:(CaliperDirection)direction bar1Position:(float)bar1Position bar2Position:(float)bar2Position crossBarPosition:(float)crossBarPosition;
- (instancetype)init;
- (void)drawWithContext:(CGContextRef)context inRect:(CGRect)rect;
- (void)setInitialPositionInRect:(CGRect)rect;
- (CGRect)rect:(CGRect)containerRect;
- (BOOL)pointNearBar:(CGPoint)p forBarPosition:(float)barPosition;
- (BOOL)pointNearCrossBar:(CGPoint)p;
- (BOOL)pointNearCaliper:(CGPoint)p;

- (float)barCoord:(CGPoint)p;






@end
