//
//  HelpModel.m
//  EP Calipers
//
//  Created by David Mann on 12/26/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

#import "HelpModel.h"
#import "HelpTopic.h"
#import "Translation.h"
#import "Defs.h"

@implementation HelpModel
- (instancetype)init {
    self = [super init];
    if (self) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        HelpTopic *quickStartTopic = [[HelpTopic alloc] initWithTopic:L(@"Quick_start_topic") text:L(@"Quick_start_text")];
        [array addObject:quickStartTopic];
        HelpTopic *loadImageTopic = [[HelpTopic alloc] initWithTopic:L(@"Load_image_topic") text:L(@"Load_image_text")];
        [array addObject:loadImageTopic];
        HelpTopic *moveCaliperTopic = [[HelpTopic alloc] initWithTopic:L(@"Move_caliper_topic") text:L(@"Move_caliper_text")];
        [array addObject:moveCaliperTopic];
        HelpTopic *addCaliperTopic = [[HelpTopic alloc] initWithTopic:L(@"Add_caliper_topic") text:L(@"Add_caliper_text")];
        [array addObject:addCaliperTopic];
        HelpTopic *selectCaliperTopic = [[HelpTopic alloc] initWithTopic:L(@"Select_caliper_topic") text:L(@"Select_caliper_text")];
        [array addObject:selectCaliperTopic];
        HelpTopic *moreCaliperOptionsTopic = [[HelpTopic alloc] initWithTopic:L(@"More_caliper_options_topic") text:L(@"More_caliper_options_text")];
        [array addObject:moreCaliperOptionsTopic];

        self.helpTopics = array;
    }
    return self;
}

@end

