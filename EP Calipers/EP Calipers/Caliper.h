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

- (instancetype)initWithDirection:(CaliperDirection)direction bar1Position:(float)bar1Position bar2Position:(float)bar2Position;
- (void)drawWithContext:(CGContextRef) context withRect:(CGRect)rect;


@end
