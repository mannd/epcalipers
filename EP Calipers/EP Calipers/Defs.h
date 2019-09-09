//
//  Defs.h
//  EP Calipers
//
//  Created by David Mann on 3/27/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#ifndef EP_Calipers_Defs_h
#define EP_Calipers_Defs_h

// Colors

// To use system colors uncomment next line, else will use "classic" colors
#define USE_SYSTEM_COLORS

// System color independent colors
#define WHITE_COLOR [UIColor whiteColor]
#define BLACK_COLOR [UIColor blackColor]

#ifdef USE_SYSTEM_COLORS

#define BLUE_COLOR [UIColor systemBlueColor]
#define RED_COLOR [UIColor systemRedColor]
// no systemMagenta exists, but systemPurple is close
#define MAGENTA_COLOR [UIColor systemPurpleColor]
#define ORANGE_COLOR [UIColor systemOrangeColor]
#define YELLOW_COLOR [UIColor systemYellowColor]
#define GREEN_COLOR [UIColor systemGreenColor]
#define GRAY_COLOR [UIColor systemGrayColor]

#else

#define BLUE_COLOR [UIColor blueColor]
#define RED_COLOR [UIColor redColor]
#define MAGENTA_COLOR [UIColor magentaColor]
#define ORANGE_COLOR [UIColor orangeColor]
#define YELLOW_COLOR [UIColor yellowColor]
#define GREEN_COLOR [UIColor greenColor]
#define GRAY_COLOR [UIColor lightGrayColor]

#endif

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

#endif
