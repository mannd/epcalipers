//
//  HelpModel.m
//  EP Calipers
//
//  Created by David Mann on 12/26/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

#import "HelpModel.h"
#import "HelpTopic.h"
#include "Defs.h"

@implementation HelpModel
- (instancetype)init {
    self = [super init];
    if (self) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        HelpTopic *addCaliperTopic = [[HelpTopic alloc] initWithTopic:L(@"Add_caliper_topic") text:L(@"Add_caliper_text")];
        [array addObject:addCaliperTopic];
        HelpTopic *moveCaliperTopic = [[HelpTopic alloc] initWithTopic:L(@"Move_caliper_topic") text:L(@"Move_caliper_text")];
        [array addObject:moveCaliperTopic];
        HelpTopic *selectCaliperTopic = [[HelpTopic alloc] initWithTopic:L(@"Select_caliper_topic") text:L(@"Select_caliper_text")];
        [array addObject:selectCaliperTopic];

        self.helpTopics = array;
    }
    return self;
}
@end

