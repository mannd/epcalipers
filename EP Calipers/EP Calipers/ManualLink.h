//
//  ManualLink.h
//  EP Calipers
//
//  Created by David Mann on 1/4/19.
//  Copyright © 2019 EP Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ManualLink : NSObject
@property (strong, nonatomic) NSString *chapter;
@property (strong, nonatomic) NSString *anchor;
- (instancetype)initWithChapter:(NSString *)chapter anchor:(NSString *)anchor;
@end

NS_ASSUME_NONNULL_END
