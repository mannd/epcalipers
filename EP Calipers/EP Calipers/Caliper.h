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
@property (strong, nonatomic) UIFont *textFont;
@property (strong, nonatomic) NSMutableParagraphStyle *paragraphStyle;
@property (strong, nonatomic) NSMutableDictionary *attributes;
@property (nonatomic) BOOL roundMsecRate;
@property (nonatomic, readonly) BOOL requiresCalibration;
@property (nonatomic) BOOL isAngleCaliper;
@property (nonatomic) BOOL marching;


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
- (BOOL)pointNearBar1:(CGPoint)p;
- (BOOL)pointNearBar2:(CGPoint)p;
- (BOOL)pointNearCrossBar:(CGPoint)p;
- (BOOL)pointNearCaliper:(CGPoint)p;
- (void)moveCrossBar:(CGPoint)delta;
- (void)moveBar1:(CGPoint)delta forLocation:(CGPoint)location;
- (void)moveBar2:(CGPoint)delta forLocation:(CGPoint)location;
- (void)moveBarInDirection:(MovementDirection)direction distance:(CGFloat)delta forComponent:(CaliperComponent)component;
- (void)moveCrossbarInDirection:(MovementDirection)direction distance:(CGFloat)delta;
- (float)barCoord:(CGPoint)p;
- (void)caliperText;
- (CaliperComponent)getCaliperComponent:(CGPoint)point;
- (NSString *)getComponentName:(CaliperComponent)component smallSize:(BOOL)smallSize;

- (NSString *)getPrefixedKey:(NSString *)prefix key:(NSString *)key;
- (void)encodeCaliperState:(NSCoder *)coder withPrefix:(NSString *)prefix;
- (void)decodeCaliperState:(NSCoder *)coder withPrefix:(NSString *)prefix;
- (BOOL)isTimeCaliper;


@end
