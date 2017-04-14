//
//  CaliperFactory.m
//  EP Calipers
//
//  Created by David Mann on 4/13/17.
//  Copyright © 2017 EP Studios. All rights reserved.
//

#import "CaliperFactory.h"
#import "AngleCaliper.h"

@implementation CaliperFactory

+ (Caliper *)createCaliper:(CaliperType) type {
    Caliper *caliper = nil;
    switch (type) {
        case Interval:
            caliper = [Caliper new];
            break;
        case Angle:
            caliper = [AngleCaliper new];
            break;
        default:
            break;
    }
    return caliper;
}

@end
