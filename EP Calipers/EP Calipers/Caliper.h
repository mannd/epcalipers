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


@property (nonatomic) float bar1Position;
@property (nonatomic) float bar2Position;
@property (nonatomic) float crossBarPosition;
@property (nonatomic) CaliperDirection direction;
@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) UIColor *unselectedColor;
@property (strong, nonatomic) UIColor *selectedColor;
@property (nonatomic) NSInteger lineWidth;
@property (readonly) float valueInPoints;
@property (nonatomic) BOOL selected;
@property (weak, nonatomic) Calibration *calibration;

- (double)intervalResult;
- (double)rateResult:(double)interval;
- (double)calibratedResult;
- (double)intervalInSecs:(double)interval;
- (double)intervalInMsec:(double)interval;
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
