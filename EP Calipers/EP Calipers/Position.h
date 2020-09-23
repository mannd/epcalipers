//
//  Position.h
//  EP Calipers
//
//  Created by David Mann on 9/22/20.
//  Copyright © 2020 EP Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Position : NSObject

+ (float)translateToAbsolutePositionX:(float)scaledPositionX offsetX:(float)offsetX scale:(float)scale;

+ (float)translateToScaledPositionX:(float)absolutePositionX offsetX:(float)offsetX scale:(float)scale;

@end

NS_ASSUME_NONNULL_END
