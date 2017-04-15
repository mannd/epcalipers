//
//  CaliperFactory.h
//  EP Calipers
//
//  Created by David Mann on 4/13/17.
//  Copyright © 2017 EP Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Defs.h"
#import "Caliper.h"

@interface CaliperFactory : NSObject

+ (Caliper *)createCaliper:(CaliperType) type;

@end
