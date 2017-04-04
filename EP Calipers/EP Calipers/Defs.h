//
//  Defs.h
//  EP Calipers
//
//  Created by David Mann on 3/27/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#ifndef EP_Calipers_Defs_h
#define EP_Calipers_Defs_h



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

#endif
