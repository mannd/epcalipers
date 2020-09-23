//
//  Position.m
//  EP Calipers
//
//  Created by David Mann on 9/22/20.
//  Copyright © 2020 EP Studios. All rights reserved.
//

#import "Position.h"

@implementation Position

+ (float)translateToAbsolutePositionX:(float)scaledPositionX offsetX:(float)offsetX scale:(float)scale {
    return (scaledPositionX + offsetX) / scale;
}

+ (float)translateToScaledPositionX:(float)absolutePositionX offsetX:(float)offsetX scale:(float)scale {
    return scale * absolutePositionX - offsetX;
}



@end
