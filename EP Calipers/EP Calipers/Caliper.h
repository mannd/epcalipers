//
//  Caliper.h
//  EP Calipers
//
//  Created by David Mann on 3/25/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Caliper : NSObject
typedef NS_ENUM(NSInteger, CaliperDirection) {
    Horizontal,
    Vertical
};
@property float bar1Position;
@property float bar2Position;
@property float crossBarPosition;
@property CaliperDirection direction;
@property UIColor *color;
@property(readonly) float valueInPoints;

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
