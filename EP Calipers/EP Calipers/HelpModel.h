//
//  HelpModel.h
//  EP Calipers
//
//  Created by David Mann on 12/26/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HelpModel : NSObject
@property (strong, nonatomic) NSArray *helpTopics;

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
