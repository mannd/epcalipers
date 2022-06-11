//
//  Caliper.m
//  EP Calipers
//
//  Created by David Mann on 3/25/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import "Caliper.h"
#import "EPSLogging.h"
#import "Translation.h"
#import "Position.h"
#import <math.h>
#import "Defs.h"
#import <EP_Calipers-Swift.h>


#define DELTA 20.0
#define MIN_DISTANCE_FOR_MARCH 20.0f
#define MAX_MARCHING_CALIPERS 20

@implementation Caliper
{
    NSInteger tmpLineWidth; // for "shaking" caliper
}

@synthesize bar1Position = _bar1Position;
@synthesize bar2Position = _bar2Position;
@synthesize crossBarPosition = _crossBarPosition;

- (float)correctedOffsetBar {
    return self.direction == Horizontal ? self.calibration.offset.x : self.calibration.offset.y;
}

- (float)correctedOffsetCrossBar {
    return self.direction == Horizontal ? self.calibration.offset.y : self.calibration.offset.x;
}

- (void)setBar1Position:(float)position {
    _bar1Position = [Position translateToAbsolutePositionX:position offsetX:[self correctedOffsetBar] scale:[self.calibration currentZoom]];
}

- (float)bar1Position {
    return [Position translateToScaledPositionX:_bar1Position offsetX:[self correctedOffsetBar] scale:[self.calibration currentZoom]];
}

- (void)setBar2Position:(float)position {
    _bar2Position = [Position translateToAbsolutePositionX:position offsetX:[self correctedOffsetBar] scale:[self.calibration currentZoom]];
}

- (float)bar2Position {
    return [Position translateToScaledPositionX:_bar2Position offsetX:[self correctedOffsetBar] scale:[self.calibration currentZoom]];
}

- (void)setCrossBarPosition:(float)position {
    _crossBarPosition = [Position translateToAbsolutePositionX:position offsetX:[self correctedOffsetCrossBar] scale:[self.calibration currentZoom]];
}

- (float)crossBarPosition {
    return [Position translateToScaledPositionX:_crossBarPosition offsetX:[self correctedOffsetCrossBar] scale:[self.calibration currentZoom]];
}

- (float)debugBar1Position {
    return _bar1Position;
}

- (instancetype)initWithDirection:(CaliperDirection)direction bar1Position:(float)bar1Position bar2Position:(float)bar2Position
                 crossBarPosition:(float)crossBarPosition calibration:(Calibration *)calibration {
    self = [super init];
    if (self) {
        self.direction = direction;
        self.calibration = calibration;
        self.bar1Position = bar1Position;
        self.bar2Position = bar2Position;
        self.crossBarPosition = crossBarPosition;
        self.unselectedColor = BLUE_COLOR;
        self.selectedColor = RED_COLOR;
        self.color = BLUE_COLOR;
        self.lineWidth = 2;
        self.selected = NO;
        self.textFont = [UIFont fontWithName:@"Helvetica" size:18.0];
        self.paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        self.attributes = [[NSMutableDictionary alloc] init];
        self.roundMsecRate = YES;
        self.isAngleCaliper = NO;
        self.marching = NO;
        self.textPosition = RightAbove;
        self.autoPositionText = YES;
        self.chosenComponent = None;
    }
    return self;
}

- (instancetype)init {
    return [self initWithDirection:Horizontal bar1Position:0 bar2Position:0 crossBarPosition:100 calibration:[[Calibration alloc] init]];
}

// set slightly different positions for each new caliper
- (void)setInitialPositionInRect:(CGRect)rect {
    static float differential = 0;
    if (self.direction == Horizontal) {
        self.bar1Position = (rect.size.width/3) + differential;
        self.bar2Position = ((2 * rect.size.width)/3) + differential;
        self.crossBarPosition = (rect.size.height/2) + differential;
    } else {
        self.bar1Position = (rect.size.height/3) + differential;
        self.bar2Position = ((2 * rect.size.height)/3) + differential;
        self.crossBarPosition = (rect.size.width/2) + differential;
    }
    differential += 15;
    if (differential > 80) {
        differential = 0;
    }
}

- (void)drawWithContext:(CGContextRef)context inRect:(CGRect)rect {
    CGContextSetStrokeColorWithColor(context, [self.color CGColor]);
    CGContextSetLineWidth(context, self.lineWidth);

    if (self.direction == Horizontal) {
        // We won't let crossbars go off the screen.  We do let regular bars go off the screen.
        self.crossBarPosition = fminf(self.crossBarPosition, rect.size.height - DELTA);
        self.crossBarPosition = fmaxf(self.crossBarPosition, DELTA);

        CGContextMoveToPoint(context, self.bar1Position, 0);
        CGContextAddLineToPoint(context, self.bar1Position, rect.size.height);
        CGContextMoveToPoint(context, self.bar2Position, 0);
        CGContextAddLineToPoint(context, self.bar2Position, rect.size.height);
        CGContextMoveToPoint(context, self.bar2Position, self.crossBarPosition);
        CGContextAddLineToPoint(context, self.bar1Position, self.crossBarPosition);

    } else {    // vertical caliper
        // We won't let crossbars go off the screen.  We do let regular bars go off the screen.
        self.crossBarPosition = fminf(self.crossBarPosition, rect.size.width - DELTA);
        self.crossBarPosition = fmaxf(self.crossBarPosition, DELTA);

        CGContextMoveToPoint(context, 0, self.bar1Position);
        CGContextAddLineToPoint(context, rect.size.width, self.bar1Position);
        CGContextMoveToPoint(context, 0, self.bar2Position);
        CGContextAddLineToPoint(context, rect.size.width, self.bar2Position);
        CGContextMoveToPoint(context, self.crossBarPosition, self.bar2Position);
        CGContextAddLineToPoint(context, self.crossBarPosition, self.bar1Position);
    }
    CGContextStrokePath(context);

    if (self.marching  && self.direction == Horizontal) {
        [self drawMarchingCalipers:context forRect:rect];
    }
    [self caliperTextInCanvas:rect textPosition:self.textPosition optimizeTextPosition:true];

    [self drawChosenComponent:context forRect:rect];
}

- (void)drawChosenComponent:(CGContextRef)context forRect:(CGRect)rect {
    if (self.chosenComponent == None) {
        return;
    }
    UIColor *chosenComponentColor;
    if (self.selected) {
        chosenComponentColor = self.unselectedColor;
    }
    else {
        chosenComponentColor = self.selectedColor;
    }
    CGContextSetStrokeColorWithColor(context, [chosenComponentColor CGColor]);
    switch (self.chosenComponent) {
        case Bar1:
            if (self.direction == Horizontal) {
                CGContextMoveToPoint(context, self.bar1Position, 0);
                CGContextAddLineToPoint(context, self.bar1Position, rect.size.height);
            }
            else {
                CGContextMoveToPoint(context, 0, self.bar1Position);
                CGContextAddLineToPoint(context, rect.size.width, self.bar1Position);
            }
            break;
        case Bar2:
            if (self.direction == Horizontal) {
                CGContextMoveToPoint(context, self.bar2Position, 0);
                CGContextAddLineToPoint(context, self.bar2Position, rect.size.height);
            }
            else {
                CGContextMoveToPoint(context, 0, self.bar2Position);
                CGContextAddLineToPoint(context, rect.size.width, self.bar2Position);
            }
            break;
        case Crossbar:
            if (self.direction == Horizontal) {
                CGContextMoveToPoint(context, self.bar2Position, self.crossBarPosition);
                CGContextAddLineToPoint(context, self.bar1Position, self.crossBarPosition);
            }
            else {
                CGContextMoveToPoint(context, self.crossBarPosition, self.bar2Position);
                CGContextAddLineToPoint(context, self.crossBarPosition, self.bar1Position);
            }
            break;
        case None:
            break;
        default:
            break;
    }
    CGContextStrokePath(context);
}

// Assumes bar1 and bar positions are already set
- (void)drawMarchingCalipers:(CGContextRef)context forRect:(CGRect)rect {
    CGFloat difference = fabs(self.bar1Position - self.bar2Position);
    if (difference < MIN_DISTANCE_FOR_MARCH) {
        return;
    }
    CGFloat greaterBar = fmaxf(self.bar1Position, self.bar2Position);
    CGFloat lesserBar = fminf(self.bar1Position, self.bar2Position);
    CGFloat biggerBars[MAX_MARCHING_CALIPERS];
    CGFloat smallerBars[MAX_MARCHING_CALIPERS];
    CGFloat point = greaterBar + difference;
    int index = 0;
    while (point < rect.size.width && index < MAX_MARCHING_CALIPERS) {
        biggerBars[index] = point;
        point += difference;
        index++;
    }
    int maxBiggerBars = index;
    index = 0;
    point = lesserBar - difference;
    while (point > 0 && index < MAX_MARCHING_CALIPERS) {
        smallerBars[index] = point;
        point -= difference;
        index++;
    }
    int maxSmallerBars = index;
    // draw them
    for (int i = 0; i < maxBiggerBars; i++) {
        CGContextMoveToPoint(context, biggerBars[i], 0);
        CGContextAddLineToPoint(context, biggerBars[i], rect.size.height);
    }
    for (int i = 0; i < maxSmallerBars; i++) {
        CGContextMoveToPoint(context, smallerBars[i], 0);
        CGContextAddLineToPoint(context, smallerBars[i], rect.size.height);
    }
    CGContextSetLineWidth(context, fmaxf(self.lineWidth - 1, 1));
    CGContextStrokePath(context);
}

- (void)caliperTextInCanvas:(CGRect)canvas textPosition:(TextPosition)textPosition optimizeTextPosition:(BOOL)optimizeTextPosition {
    NSString *text = [self measurement];
    self.paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    self.paragraphStyle.alignment = NSTextAlignmentCenter;

    [self.attributes setObject:self.textFont forKey:NSFontAttributeName];
    [self.attributes setObject:self.paragraphStyle forKey:NSParagraphStyleAttributeName];
    [self.attributes setObject:self.color forKey:NSForegroundColorAttributeName];

    CGSize size = [text sizeWithAttributes:self.attributes];

    CGRect textPositionRect = [self caliperTextPosition:textPosition left:fminf(self.bar1Position, self.bar2Position) right:fmaxf(self.bar1Position, self.bar2Position) center:self.crossBarPosition size:size canvas:canvas optimizeTextPosition:optimizeTextPosition];
    [text drawInRect:textPositionRect withAttributes:self.attributes];
}

- (CGRect)caliperTextPosition:(TextPosition)textPosition left:(CGFloat)left right:(CGFloat)right center:(CGFloat)center size:(CGSize)size canvas:(CGRect)canvas optimizeTextPosition:(BOOL)optimizeTextPosition {
    // Position of our text, based on Center text alignment
    // This assumes X is the center of the text block, and Y is the text baseline.
    CGPoint textOrigin = CGPointMake(0, 0);
    // This is the point used as the origin from which to calculate the textOrigin.
    // This will vary depending on the TextPosition.
    CGPoint origin = CGPointMake(0, 0);
    CGFloat textHeight = size.height;
    CGFloat textWidth = size.width;
    CGFloat yOffset = 6;
    CGFloat xOffset = 12;
    if (self.direction == Horizontal) {
        // Guard against the margin obscuring left and right labels.
        TextPosition optimizedPosition = [self optimizedTextPosition:textPosition canvas:canvas left:left right:right center:center textWidth:textWidth textHeight:textHeight optimizeTextPosition:optimizeTextPosition];
        origin.y = center;
        switch (optimizedPosition) {
            case CenterAbove:
                origin.x = left + (right - left) / 2;
                textOrigin.x = origin.x;
                textOrigin.y = origin.y - yOffset;
                break;
            case CenterBelow:
                origin.x = left + (right - left) / 2;
                textOrigin.x = origin.x;
                textOrigin.y = origin.y + yOffset + textHeight;
                break;
            case LeftAbove:
                origin.x = left;
                textOrigin.x = origin.x - xOffset - textWidth / 2;
                textOrigin.y = origin.y - yOffset;
                break;
            case RightAbove:
                origin.x = right;
                textOrigin.x = origin.x + xOffset + textWidth / 2;
                textOrigin.y = origin.y - yOffset;
                break;
            default:
                NSAssert(NO, @"Invalid TextPosition.");
                break;
        }
    }
    else {  // Vertical (amplitude) caliper
        textOrigin.y = textHeight / 2 + left + (right - left) / 2;
        TextPosition optimizedPosition = [self optimizedTextPosition:textPosition canvas:canvas left:left right:right center:center textWidth:textWidth textHeight:textHeight optimizeTextPosition:optimizeTextPosition];
        switch (optimizedPosition) {
            case LeftAbove:
                textOrigin.x = center - xOffset - textWidth / 2;
                break;
            case RightAbove:
                textOrigin.x = center + xOffset + textWidth / 2;
                break;
            case Top:
                textOrigin.y = left - yOffset;
                textOrigin.x = center;
                break;
            case Bottom:
                textOrigin.y = right + yOffset + textHeight;
                textOrigin.x = center;
                break;
            default:
//                if (BuildConfig.DEBUG) {
//                    throw new AssertionError("Invalid TextPosition.");
//                }
                break;
        }
    }
    return CGRectMake(textOrigin.x - textWidth / 2, textOrigin.y - textHeight, textWidth, textHeight);
}


- (TextPosition)optimizedTextPosition:(TextPosition)textPosition canvas:(CGRect)canvas left:(CGFloat)left right:(CGFloat)right center:(CGFloat)center textWidth:(CGFloat)textWidth textHeight:(CGFloat)textHeight optimizeTextPosition:(BOOL) optimizeTextPosition {
    // Just use textPosition if not auto-positioning text
    if (!self.autoPositionText || !optimizeTextPosition) {
        return textPosition;
    }
    // Allow a few pixels margin so that screen edge never obscures text.
    float offset = 4;
    TextPosition optimizedPosition = textPosition;
    if (self.direction == Horizontal) {
        switch (optimizedPosition) {
            case CenterAbove:
            case CenterBelow:
                // avoid squeezing label
                if (textWidth + offset > right - left) {
                    if (textWidth + right + offset > canvas.size.width) {
                        optimizedPosition = LeftAbove;
                    }
                    else {
                        optimizedPosition = RightAbove;
                    }
                }
                break;
            case Left:
                if (textWidth + offset > left) {
                    if (textWidth + right + offset > canvas.size.width) {
                        optimizedPosition = CenterAbove;
                    } else {
                        optimizedPosition = RightAbove;
                    }
                }
                break;
            case Right:
                if (textWidth + right + offset > canvas.size.width) {
                    if (textWidth + offset > left) {
                        optimizedPosition = CenterAbove;
                    } else {
                        optimizedPosition = LeftAbove;
                    }
                }
                break;
            default:
                optimizedPosition = textPosition;
        }
    }
    else if (self.direction == Vertical) {
        // watch for squeeze
        if ((optimizedPosition == LeftAbove || optimizedPosition == RightAbove)
            && (textHeight + offset > right - left)) {
            if (left - textHeight - offset < 0) {
                optimizedPosition = Bottom;
            }
            else {
                optimizedPosition = Top;
            }
        }
        else {
            switch (optimizedPosition) {
                case LeftAbove:
                    if (textWidth + offset > center) {
                        optimizedPosition = RightAbove;
                    }
                    break;
                case RightAbove:
                    if (textWidth + center + offset > canvas.size.width) {
                        optimizedPosition = LeftAbove;
                    }
                    break;
                case Top:
                    if (left - textHeight - offset < 0) {
                        if (right + textHeight + offset > canvas.size.height) {
                            optimizedPosition = RightAbove;
                        } else {
                            optimizedPosition = Bottom;
                        }
                    }
                    break;
                case Bottom:
                    if (right + textHeight + offset > canvas.size.height) {
                        if (left - textHeight - offset < 0) {
                            optimizedPosition = RightAbove;
                        } else {
                            optimizedPosition = Top;
                        }
                    }
                    break;
                default:
                    optimizedPosition = textPosition;
            }
        }
    }
    return optimizedPosition;
}


// returns significant bar coordinate depending on direction of caliper
- (float)barCoord:(CGPoint)p {
    return (self.direction == Horizontal ? p.x : p.y);
}

- (NSString *)measurement {
    NSString *s = [NSString localizedStringWithFormat:@"%.4g %@", [self calibratedResult], self.calibration.units];
    return s;
}

- (double)calibratedResult {
    double result = [self intervalResult];
    if (result != 0 && self.calibration.displayRate && self.calibration.canDisplayRate) {
        result = [self rateResult:result];
    }
    else if (self.roundMsecRate && self.calibration.unitsAreMsec) {
        result = round(result);
    }
    return result;
}

- (double)intervalResult {
    return [self points] * self.calibration.multiplier;
}

- (double)rateResult:(double)interval {
    if (interval != 0) {
        if (self.calibration.unitsAreMsec) {
            interval = 60000.0 / interval;
        }
        if (self.calibration.unitsAreSeconds) {
            interval = 60.0 / interval;
        }
    }
    if (self.roundMsecRate) {
        interval = round(interval);
    }
    return interval;
}

- (double)intervalInSecs:(double)interval {
    if (self.calibration.unitsAreSeconds) {
        return interval;
    }
    else {
        return interval / 1000;
    }
}

- (double)intervalInMsec:(double)interval {
    if (self.calibration.unitsAreMsec) {
        return interval;
    }
    else {
        return 1000 * interval;
    }
}

- (float) points {
    return self.bar2Position - self.bar1Position;
}

- (float)valueInPoints {
    return self.bar2Position - self.bar1Position;
}

- (BOOL)pointNearBar:(CGPoint)p forBarPosition:(float)barPosition {
    return [self barCoord:p] > barPosition - DELTA && [self barCoord:p] < barPosition + DELTA;
}

- (BOOL)pointNearBar1:(CGPoint)p {
    return [self pointNearBar:p forBarPosition:self.bar1Position];
}

- (BOOL)pointNearBar2:(CGPoint)p {
    return [self pointNearBar:p forBarPosition:self.bar2Position];
}

- (BOOL)pointNearCrossBar:(CGPoint)p {
    BOOL nearBar = NO;
    float delta = DELTA + 5.0f; // make cross bar delta a little bigger
    // avoid overlapping deltas inside calipers that prevent crossbar touch when short interval
    if (self.direction == Horizontal) {
        nearBar = (p.x > fminf(self.bar1Position, self.bar2Position) && p.x < fmaxf(self.bar2Position, self.bar1Position) && p.y > self.crossBarPosition - delta && p.y < self.crossBarPosition + delta);
    } else {
        nearBar = (p.y > fminf(self.bar1Position, self.bar2Position) && p.y < fmaxf(self.bar2Position, self.bar1Position) && p.x > self.crossBarPosition - delta && p.x < self.crossBarPosition + delta);
    }
    return nearBar;
}

- (BOOL)pointNearCaliper:(CGPoint)p {
    return ([self pointNearCrossBar:p] || [self pointNearBar:p forBarPosition:self.bar1Position] || [self pointNearBar:p forBarPosition:self.bar2Position]);
}

- (CaliperComponent)getCaliperComponent:(CGPoint)p{
    if ([self pointNearCrossBar:p]) {
        return Crossbar;
    }
    else if ([self pointNearBar1:p]) {
        return Bar1;
    }
    else if ([self pointNearBar2:p]) {
        return Bar2;
    }
    else {
        return None;
    }
}

- (void)moveCrossBar:(CGPoint)delta {
    self.bar1Position += delta.x;
    self.bar2Position += delta.x;
    self.crossBarPosition += delta.y;
}

- (void)moveBar1:(CGPoint)delta forLocation:(CGPoint)location {
    self.bar1Position += delta.x;
}

- (void)moveBar2:(CGPoint)delta forLocation:(CGPoint)location {
    self.bar2Position += delta.x;
}

- (void)moveBarInDirection:(MovementDirection)direction distance:(CGFloat)delta forComponent:(CaliperComponent)component {
    if (component == Crossbar) {
        [self moveCrossbarInDirection:direction distance:delta];
        return;
    }
    if (direction == Up || direction == Left) {
        delta = -delta;
    }
    switch (component) {
        case Bar1:
            self.bar1Position += delta;
            break;
        case Bar2:
            self.bar2Position += delta;
            break;
        default:
            break;
    }
}

// swaps up and down for right and left, when using vertical calipers
- (MovementDirection)swapDirection:(MovementDirection)direction {
    switch (direction) {
        case Left:
            return Up;
            break;
        case Right:
            return Down;
            break;
        case Up:
            return Left;
            break;
        case Down:
            return Right;
            break;
        default:
            return Stationary;
            break;
    }
}

- (void)moveCrossbarInDirection:(MovementDirection)direction distance:(CGFloat)delta {
    // assume origin at upper left
    if (self.direction == Vertical) {
        direction = [self swapDirection:direction];
    }
    switch (direction) {
        case Up:
            self.crossBarPosition -= delta;
            break;
        case Down:
            self.crossBarPosition += delta;
            break;
        case Left:
            self.bar1Position -= delta;
            self.bar2Position -= delta;
            break;
        case Right:
            self.bar1Position += delta;
            self.bar2Position += delta;
            break;
        default:
            break;
    }
}

- (BOOL)requiresCalibration {
    return YES;
}

- (BOOL)isTimeCaliper {
    return self.direction == Horizontal && !self.isAngleCaliper;
}

// preserve state
// duplicated in Calibration.m
- (NSString *)getPrefixedKey:(NSString *)prefix key:(NSString *)key {
    return [NSString stringWithFormat:@"%@%@", prefix, key];
}

- (void)encodeCaliperState:(NSCoder *)coder withPrefix:(NSString *)prefix {
    [coder encodeBool:[self isAngleCaliper] forKey:[self getPrefixedKey:prefix key:@"IsAngleCaliper"]];
    [coder encodeInteger:self.direction forKey:[self getPrefixedKey:prefix key:@"Direction"]];
    [coder encodeDouble:_bar1Position forKey:[self getPrefixedKey:prefix key:@"Bar1Position"]];
    [coder encodeDouble:_bar2Position forKey:[self getPrefixedKey:prefix key:@"Bar2Position"]];
    [coder encodeDouble:_crossBarPosition forKey:[self getPrefixedKey:prefix key:@"CrossBarPosition"]];
    [coder encodeBool:self.selected forKey:[self getPrefixedKey:prefix key:@"Selected"]];
    [coder encodeInteger:self.lineWidth forKey:[self getPrefixedKey:prefix key:@"LineWidth"]];
    [coder encodeBool:self.roundMsecRate forKey:[self getPrefixedKey:prefix key:@"RoundMsecRate"]];
    [coder encodeBool:self.marching forKey:[self getPrefixedKey:prefix key:@"Marching"]];

    NSString *unselectedColorString = self.unselectedColor.toString;
    [coder encodeObject:unselectedColorString forKey:[self getPrefixedKey:prefix key:@"UnselectedColorString"]];
    NSString *colorString = self.color.toString;
    [coder encodeObject:colorString forKey:[self getPrefixedKey:prefix key:@"ColorString"]];
    NSString *selectedColorString = self.selectedColor.toString;
    [coder encodeObject:selectedColorString forKey:[self getPrefixedKey:prefix key:@"SelectedColorString"]];
}

// need to deal with two types of objects: angle and regular calipers
// calling function to extract whether is angle caliper or not
- (void)decodeCaliperState:(NSCoder *)coder withPrefix:(NSString *)prefix {
    self.isAngleCaliper = [coder decodeBoolForKey:[self getPrefixedKey:prefix key:@"IsAngleCaliper"]];
    self.direction = [coder decodeIntegerForKey:[self getPrefixedKey:prefix key:@"Direction"]];
    _bar1Position = [coder decodeDoubleForKey:[self getPrefixedKey:prefix key:@"Bar1Position"]];
    _bar2Position = [coder decodeDoubleForKey:[self getPrefixedKey:prefix key:@"Bar2Position"]];
    _crossBarPosition = [coder decodeDoubleForKey:[self getPrefixedKey:prefix key:@"CrossBarPosition"]];
    self.selected = [coder decodeBoolForKey:[self getPrefixedKey:prefix key:@"Selected"]];
    self.lineWidth = [coder decodeIntegerForKey:[self getPrefixedKey:prefix key:@"LineWidth"]];
    self.roundMsecRate = [coder decodeBoolForKey:[self getPrefixedKey:prefix key:@"RoundMsecRate"]];
    self.marching = [coder decodeBoolForKey:[self getPrefixedKey:prefix key:@"Marching"]];

    [self decodeColorKey:[self getPrefixedKey:prefix key:@"UnselectedColorString"] forCaliperColor:self.unselectedColor coder:coder];
    [self decodeColorKey:[self getPrefixedKey:prefix key:@"ColorString"] forCaliperColor:self.color coder:coder];
    [self decodeColorKey:[self getPrefixedKey:prefix key:@"SelectedColorString"] forCaliperColor:self.selectedColor coder:coder];
}

- (void)decodeColorKey:(NSString *)key forCaliperColor:(UIColor *)caliperColor coder:(NSCoder *) coder {
    NSString *colorString = [coder decodeObjectForKey:key];
    assert(colorString != nil);
    if (colorString != nil) {
        UIColor *color = [UIColor convertColorName:colorString];
        assert(color != nil);
        if (color != nil) {
            caliperColor = color;
        }
    }
    EPSLog(@"colorString = %@", colorString);
}

- (CGPoint)getCaliperMidPoint {
    CGPoint point = CGPointMake(0, 0);
    CGFloat x = fabs(self.bar2Position - self.bar1Position) / 2 + fmin(self.bar1Position, self.bar2Position);
    CGFloat y = self.crossBarPosition;
    if (self.direction == Horizontal) {
        point.x = x;
        point.y = y;
    }
    else {
        point.x = y;
        point.y = x;
    }
    return point;
}


@end
