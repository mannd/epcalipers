//
//  HelpViewModel.m
//  EP Calipers
//
//  Created by David Mann on 12/26/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

#import "HelpViewModel.h"

@implementation HelpViewModel
- (instancetype)initWithTopic:(NSString *)topic text:(NSString *)text {
    self = [super init];
    if (self) {
        self.topic = topic;
        self.text = text;
        self.expanded = NO;
    }
    return self;
}

- (instancetype)initWithHelpTopic:(HelpTopic *)helpTopic {
    return [self initWithTopic:helpTopic.topic text:helpTopic.text];
}

@end
