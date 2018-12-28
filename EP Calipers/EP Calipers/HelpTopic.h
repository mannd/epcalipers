//
//  HelpObject.h
//  EP Calipers
//
//  Created by David Mann on 12/26/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HelpTopic : NSObject
@property (strong, nonatomic) NSString *topic;
@property (strong, nonatomic) NSString *text;

- (instancetype)initWithTopic:(NSString *)topic text:(NSString *)text;
@end

NS_ASSUME_NONNULL_END
