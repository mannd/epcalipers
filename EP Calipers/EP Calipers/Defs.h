//
//  Defs.h
//  EP Calipers
//
//  Created by David Mann on 3/27/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#ifndef EP_Calipers_Defs_h
#define EP_Calipers_Defs_h

typedef NS_ENUM(NSInteger, CaliperType) {
    Interval,
    Angle
};

typedef NS_ENUM(NSInteger, CaliperDirection) {
    Horizontal,
    Vertical
};

typedef NS_ENUM(NSInteger, CaliperComponent) {
    Bar1,
    Bar2,
    Crossbar,
    None
};

typedef NS_ENUM(NSInteger, MovementDirection) {
    Up,
    Down,
    Left,
    Right,
    Stationary
};

typedef NS_ENUM(NSInteger, TextPosition) {
    CenterAbove = 0,
    CenterBelow,
    LeftAbove,
    RightAbove,
    Top,
    Bottom
};

// Look for untranslated string by default.
#ifdef DEBUG
#define X(s) [NSString stringWithFormat:@"*<%@>*", s]
#define L(s) NSLocalizedStringWithDefaultValue(s, @"Localizable", [NSBundle mainBundle], X(s), @"")
#else
// make my own simpler localization macrt
#define L(s) NSLocalizedString(s, nil)
#endif

#endif
