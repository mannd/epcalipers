//
//  HelpViewModel.h
//  EP Calipers
//
//  Created by David Mann on 12/26/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HelpTopic.h"

NS_ASSUME_NONNULL_BEGIN

@interface HelpViewModel : NSObject

@property (strong, nonatomic) NSString *topic;
@property (strong, nonatomic) NSString *text;
@property (nonatomic) BOOL expanded;

- (instancetype)initWithTopic:(NSString *)topic text:(NSString *)text;
- (instancetype)initWithHelpTopic:(HelpTopic *)helpTopic;
@end

NS_ASSUME_NONNULL_END
